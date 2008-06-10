package popcraft.ui {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.*;
import popcraft.data.ResourceData;
import popcraft.sp.PauseMode;

public class DashboardView extends SceneObject
{
    public function DashboardView ()
    {
        _movie = SwfResource.instantiateMovieClip("dashboard", "dashboard_sym");
        _shuffleMovie = _movie["shuffle"];

        var puzzleFrame :MovieClip = this.puzzleFrame;

        _movie.cacheAsBitmap = true;
        puzzleFrame.cacheAsBitmap = true;

        _infoPanel = new InfoPanel(_movie);

        // setup resources
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resourceTextName :String = RESOURCE_TEXT_NAMES[resType];
            _resourceText.push(puzzleFrame[resourceTextName]);
            _resourceBars.push(null);
            _oldResourceAmounts.push(-1);
        }

        // setup unit purchase buttons
        var unitParent :MovieClip = _movie["frame_units"];
        unitParent.cacheAsBitmap = true;

        var buttonNumber :int = 1;
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            if (GameContext.isSinglePlayer && !GameContext.spLevel.isAvailableUnit(unitType)) {
                // don't create buttons for unavailable units
                continue;
            }

            GameContext.gameMode.addObject(new CreaturePurchaseButton(unitType, buttonNumber++, unitParent));
        }

        // hide the components of all the buttons that aren't being used
        for ( ; buttonNumber < Constants.UNIT_TYPE__CREATURE_LIMIT + 1; ++buttonNumber) {
            DisplayObject(unitParent["switch_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["cost_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["highlight_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["unit_" + buttonNumber]["unit"]).visible = false;
            DisplayObject(unitParent["progress_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["button_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["multiplicity_" + buttonNumber]).visible = false;
        }

        // setup PlayerStatusViews
        var statusViewLocs :Array = PLAYER_STATUS_VIEW_LOCS[GameContext.playerInfos.length - 2];
        var playerFrame :MovieClip = _movie["frame_players"];
        for (var i :int = 0; i < statusViewLocs.length; ++i) {
            var playerInfo :PlayerInfo = GameContext.playerInfos[i];
            var loc :Point = statusViewLocs[i];

            var psv :PlayerStatusView = new PlayerStatusView(playerInfo.playerId);
            psv.x = loc.x;
            psv.y = loc.y;
            GameContext.gameMode.addObject(psv, playerFrame);
        }

        // pause button only visible in single-player games
        var pauseButton :SimpleButton = _movie["pause"];
        if (GameContext.isSinglePlayer) {
            pauseButton.visible = true;
            pauseButton.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void { MainLoop.instance.pushMode(new PauseMode()); });
        } else {
            pauseButton.visible = false;
        }

        // _spellSlots keeps track of whether the individual spell slots are occupied
        // or empty
        for (i = 0; i < GameContext.gameData.maxSpells; ++i) {
            _spellSlots.push(false);
        }

        // we need to know when the player gets a spell
        GameContext.localPlayerInfo.addEventListener(GotSpellEvent.GOT_SPELL, onGotSpell);

        this.updateResourceMeters();
    }

    override protected function addedToDB () :void
    {
        this.db.addObject(_infoPanel);

        // add any spells the player already has to the dashboard
        for (var spellType :uint = 0; spellType < Constants.SPELL_TYPE__LIMIT; ++spellType) {
            var count :uint = GameContext.localPlayerInfo.getSpellCount(spellType);
            for (var i :uint = 0; i < count; ++i) {
                this.createSpellButton(spellType, false);
            }
        }
    }

    public function puzzleShuffle () :void
    {
        // when the "shuffle" spell is cast, we show an animation in the
        // Dashboard, and then reset the puzzle
        _shuffleMovie.gotoAndPlay("go");

        this.addNamedTask(
            PUZZLE_SHUFFLE_TASK,
            new SerialTask(
                new WaitForFrameTask("swap", _shuffleMovie),
                new FunctionTask(function () :void { GameContext.puzzleBoard.puzzleReset(false); })),
            true);

        GameContext.playGameSound("sfx_puzzlereset");
    }

    protected function onGotSpell (e :GotSpellEvent) :void
    {
        this.createSpellButton(e.spellType, true);
    }

    protected function createSpellButton (spellType :uint, animateIn :Boolean) :void
    {
        // find the first free spell slot to put this spell in
        var slot :int = -1;
        for (var i :int = 0; i < _spellSlots.length; ++i) {
            if (!Boolean(_spellSlots[i])) {
                slot = i;
                break;
            }
        }

        if (slot < 0) {
            // this should never happen
            return;
        }

        _spellSlots[slot] = true; // occupy the slot

        // create a new icon
        var spellButton :SpellButton = new SpellButton(spellType, slot, animateIn);
        spellButton.clickableObject.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void { onSpellButtonClicked(spellButton); });

        this.db.addObject(spellButton, _movie);
    }

    protected function onSpellButtonClicked (spellButton :SpellButton) :void
    {
        if (!spellButton.isLiveObject) {
            // prevent unlikely but possible multiple clicks on a button
            return;
        }

        if (!spellButton.isCastable) {
            spellButton.showUncastableJiggle();
        } else {
            GameContext.gameMode.castSpell(GameContext.localPlayerId, spellButton.spellType);
            // un-occupy the slot
            _spellSlots[spellButton.slot] = false;
            spellButton.destroySelf();
        }
    }

    public function showInfoText (text :String) :void
    {
        _infoPanel.show(text);
    }

    public function hideInfoText () :void
    {
        _infoPanel.hide();
    }

    public function get puzzleFrame () :MovieClip
    {
        return _movie["frame_puzzle"];
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        this.updateResourceMeters();

        // when the player dies, show the death panel
        if (!_showingDeathPanel && !GameContext.localPlayerInfo.isAlive) {
            var deathPanel :MovieClip = _movie["death"];
            deathPanel.y = 6;
            deathPanel.visible = true;
            _showingDeathPanel = true;
        }
    }

    protected function updateResourceMeters () :void
    {
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            this.updateResourceMeter(resType);
        }
    }

    protected function updateResourceMeter (resType :uint) :void
    {
        var resAmount :int = GameContext.localPlayerInfo.getResourceAmount(resType);

        // only update if the resource amount has changed
        if (resAmount == _oldResourceAmounts[resType]) {
            return;
        }

        _oldResourceAmounts[resType] = resAmount;

        var textField :TextField = _resourceText[resType];
        textField.text = String(resAmount);

        var puzzleFrame :MovieClip = this.puzzleFrame;
        var resourceBarParent :Sprite = _resourceBars[resType];

        if (null == resourceBarParent) {
            resourceBarParent = new Sprite();
            _resourceBars[resType] = resourceBarParent;
            puzzleFrame.addChildAt(resourceBarParent, 1);
        }

        var g :Graphics = resourceBarParent.graphics;
        g.clear();

        if (resAmount > 0) {
            var color :uint = ResourceData(GameContext.gameData.resources[resType]).color;
            var meterLoc :Point = RESOURCE_METER_LOCS[resType];

            g.lineStyle(1, 0);
            g.beginFill(color);
            g.drawRect(
                meterLoc.x,
                meterLoc.y,
                1 + (RESOURCE_METER_WIDTH * (resAmount / GameContext.gameData.maxResourceAmount)),
                RESOURCE_METER_HEIGHT);
            g.endFill();
        }
    }

    protected var _movie :MovieClip;
    protected var _shuffleMovie :MovieClip;
    protected var _resourceText :Array = [];
    protected var _resourceBars :Array = [];
    protected var _oldResourceAmounts :Array = [];
    protected var _showingDeathPanel :Boolean;
    protected var _infoPanel :InfoPanel;
    protected var _spellSlots :Array = []; // of Booleans

    protected static const PUZZLE_SHUFFLE_TASK :String = "PuzzleShuffle";

    protected static const RESOURCE_TEXT_NAMES :Array =
        [ "resource_2", "resource_1", "resource_4", "resource_3" ];

    protected static const RESOURCE_METER_LOCS :Array =
        [ new Point(-65, 44), new Point(-134, 44), new Point(73, 44), new Point(4, 44) ];

    protected static const RESOURCE_METER_WIDTH :Number = 63;
    protected static const RESOURCE_METER_HEIGHT :Number = 20;

    protected static const PLAYER_STATUS_VIEW_LOCS :Array = [
        [ new Point(40, 47), new Point(105, 47) ],                                          // 2 players
        [ new Point(40, 47), new Point(105, 47), new Point(170, 47), ],                     // 3 players
        [ new Point(29, 47), new Point(81, 47), new Point(133, 47), new Point(185, 47) ],   // 4 players
    ];
}

}

import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.text.TextField;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.resource.*;
import flash.display.InteractiveObject;

class InfoPanel extends SceneObject
{
    public function InfoPanel (parent :MovieClip)
    {
        _infoTextParent = parent["info"];
        _infoText = _infoTextParent["info_text"];
        _infoTextParent.y = 6;
        _infoTextParent.visible = false;

        _infoTextParent.cacheAsBitmap = true;
    }

    override public function get displayObject () :DisplayObject
    {
        return _infoTextParent;
    }

    public function show (text :String) :void
    {
        _infoText.text = text;

        if (!this.hasTasksNamed(SHOW_TASK_NAME)) {
            // we're not already being shown

            if (this.hasTasksNamed(HIDE_TASK_NAME)) {
                // the panel is in the process of being hidden
                this.removeNamedTasks(HIDE_TASK_NAME);
                _infoTextParent.y = VISIBLE_Y;
                this.visible = true;

            } else if (!this.visible) {
                // the panel is already hidden
                _infoTextParent.y = HIDDEN_Y;

                var showTask :SerialTask = new SerialTask();
                showTask.addTask(new TimedTask(SHOW_DELAY));
                showTask.addTask(new VisibleTask(true));
                showTask.addTask(LocationTask.CreateSmooth(_infoTextParent.x, VISIBLE_Y, SLIDE_TIME));
                this.addNamedTask(SHOW_TASK_NAME, showTask);
            }
        }
    }

    public function hide () :void
    {
        if (!this.hasTasksNamed(HIDE_TASK_NAME)) {
            // we're not already being hidden

            if (this.hasTasksNamed(SHOW_TASK_NAME)) {
                // the panel is in the process of being shown
                this.removeNamedTasks(SHOW_TASK_NAME);
                this.visible = false;

            } else if (this.visible) {
                // the panel is already visible
                var hideTask :SerialTask = new SerialTask();
                hideTask.addTask(LocationTask.CreateSmooth(_infoTextParent.x, HIDDEN_Y, SLIDE_TIME));
                hideTask.addTask(new VisibleTask(false));
                this.addNamedTask(HIDE_TASK_NAME, hideTask);
            }
        }
    }

    protected var _infoTextParent :MovieClip;
    protected var _infoText :TextField;

    protected static const SHOW_TASK_NAME :String = "Show";
    protected static const HIDE_TASK_NAME :String = "Hide";

    protected static const SHOW_DELAY :Number = 0.7;
    protected static const SLIDE_TIME :Number = 0.2;
    protected static const VISIBLE_Y :Number = 6;
    protected static const HIDDEN_Y :Number = 121;
}
