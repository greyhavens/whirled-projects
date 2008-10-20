package popcraft.ui {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
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
import popcraft.util.SpriteUtil;

public class DashboardView extends SceneObject
{
    public function DashboardView ()
    {
        _movie = SwfResource.instantiateMovieClip("dashboard", "dashboard_sym");
        _shuffleMovie = _movie["shuffle"];

        var puzzleFrame :MovieClip = this.puzzleFrame;

        _movie.cacheAsBitmap = true;
        puzzleFrame.cacheAsBitmap = true;

        _deathPanel = _movie["death"];

        // the info panel is no longer used
        var infoPanel :MovieClip = _movie["info"];
        if (null != infoPanel) {
            _movie.removeChild(infoPanel);
        }

        // setup resources
        for (var resType :int = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resourceTextName :String = RESOURCE_TEXT_NAMES[resType];
            var resourceText :TextField = puzzleFrame[resourceTextName];
            var resourceTextObj :SimpleSceneObject = new SimpleSceneObject(resourceText);
            GameContext.gameMode.addObject(resourceTextObj);
            _resourceTextObjs.push(resourceTextObj);
            _resourceBars.push(null);
            _oldResourceAmounts.push(-1);
        }

        // setup unit purchase buttons
        var unitParent :MovieClip = _movie["frame_units"];
        unitParent.cacheAsBitmap = true;

        var buttonNumber :int = 1;
        for (var unitType :int = 0; unitType < Constants.UNIT_TYPE__PLAYER_CREATURE_LIMIT; ++unitType) {
            if (!GameContext.gameMode.isAvailableUnit(unitType)) {
                // don't create buttons for unavailable units
                continue;
            }

            GameContext.gameMode.addObject(new CreaturePurchaseButton(unitType, buttonNumber++, unitParent));
        }

        // hide the components of all the buttons that aren't being used
        for ( ; buttonNumber < Constants.UNIT_TYPE__PLAYER_CREATURE_LIMIT + 1; ++buttonNumber) {
            DisplayObject(unitParent["switch_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["cost_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["highlight_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["unit_" + buttonNumber]["unit"]).visible = false;
            DisplayObject(unitParent["progress_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["button_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["multiplicity_" + buttonNumber]).visible = false;
        }

        // setup PlayerStatusViews
        this.updatePlayerStatusViews();

        // pause button only visible in single-player games
        var pauseButton :SimpleButton = _movie["pause"];
        if (GameContext.gameMode.canPause) {
            pauseButton.visible = true;
            this.registerEventListener(pauseButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    MainLoop.instance.pushMode(new PauseMode());
                });

        } else {
            pauseButton.visible = false;
        }

        // _spellSlots keeps track of whether the individual spell slots are occupied
        // or empty
        var numSlots :int = GameContext.gameData.maxSpellsPerType * Constants.CASTABLE_SPELL_TYPE__LIMIT;
        for (var ii :int = 0; ii < numSlots; ++ii) {
            _spellSlots.push(false);
        }

        // we need to know when the player gets a spell
        this.registerEventListener(GameContext.localPlayerInfo, GotSpellEvent.GOT_SPELL,
            onGotSpell);

        this.updateResourceMeters();
    }

    public function updatePlayerStatusViews () :void
    {
        var playerInfo :PlayerInfo;

        var deadViews :Array = [];
        var liveViews :Array = [];

        // discover which existing views are dead
        for each (var existingStatusView :PlayerStatusView in _playerStatusViews) {
            if (existingStatusView.isAlive) {
                liveViews.push(existingStatusView);
            } else {
                deadViews.push(existingStatusView);
            }
        }

        // discover which players don't have views created for them
        for each (playerInfo in GameContext.playerInfos) {
            if (ArrayUtil.findIf(liveViews,
                function (view :PlayerStatusView) :Boolean {
                    return (view.playerInfo == playerInfo);
                }) == null) {
                liveViews.push(new PlayerStatusView(playerInfo.playerIndex));
            }
        }

        // destroy dead views
        for each (var deadView :PlayerStatusView in deadViews) {
            deadView.addTask(new SerialTask(
                LocationTask.CreateEaseIn(deadView.x, 47 + deadView.height, VIEW_MOVE_TIME),
                new SelfDestructTask()));
        }

        // sort the live views by playerIndex
        liveViews.sort(
            function (a :PlayerStatusView, b :PlayerStatusView) :int {
                var aIndex :int = a.playerInfo.playerIndex;
                var bIndex :int = b.playerInfo.playerIndex;
                if (aIndex < bIndex) {
                    return -1;
                } else if (aIndex > bIndex) {
                    return 1;
                } else {
                    return 0;
                }
            });

        var statusViewLocs :Array = PLAYER_STATUS_VIEW_LOCS[liveViews.length - 2];
        var playerFrame :MovieClip = _movie["frame_players"];
        for (var ii :int = 0; ii < liveViews.length; ++ii) {
            var liveView :PlayerStatusView = liveViews[ii];
            var loc :Point = statusViewLocs[ii];

            // add the view to the DB if it was just created
            if (!liveView.isLiveObject) {
                liveView.x = loc.x;
                liveView.y = loc.y + liveView.height;
                GameContext.gameMode.addObject(liveView, playerFrame);
            }

            // animate the view to its new location
            liveView.addTask(LocationTask.CreateEaseOut(loc.x, loc.y, VIEW_MOVE_TIME));

        }

        _playerStatusViews = liveViews;
    }

    override protected function addedToDB () :void
    {
        // add any spells the player already has to the dashboard
        for (var spellType :int = 0; spellType < Constants.CASTABLE_SPELL_TYPE__LIMIT; ++spellType) {
            var count :int = GameContext.localPlayerInfo.getSpellCount(spellType);
            for (var i :int = 0; i < count; ++i) {
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
                new FunctionTask(function () :void { GameContext.puzzleBoard.puzzleShuffle(); })),
            true);

        GameContext.playGameSound("sfx_puzzleshuffle");
    }

    protected function onGotSpell (e :GotSpellEvent) :void
    {
        this.createSpellButton(e.spellType, true);
    }

    protected function createSpellButton (spellType :int, animateIn :Boolean) :void
    {
        // find the first free spell slot to put this spell in
        var numSlotsForType :int = GameContext.gameData.maxSpellsPerType;

        var slot :int = -1;
        var firstSlot :int = spellType * numSlotsForType;
        var lastSlot :int = (spellType + 1) * numSlotsForType;
        for (var i :int = firstSlot; i <= lastSlot; ++i) {
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
        this.registerEventListener(spellButton.clickableObject, MouseEvent.CLICK,
            function (...ignored) :void {
                onSpellButtonClicked(spellButton);
            });

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
            GameContext.gameMode.castSpell(GameContext.localPlayerIndex, spellButton.spellType,
                false);
            // un-occupy the slot
            _spellSlots[spellButton.slot] = false;
            spellButton.destroySelf();
        }
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
        var playerDead :Boolean = !GameContext.localPlayerInfo.isAlive;
        if (!this.showingDeathPanel && playerDead) {
            _deathPanel.y = 6;
            _deathPanel.visible = true;

        } else if (this.showingDeathPanel && !playerDead) {
            _deathPanel.visible = false;
        }

        // resurrect button
        var shouldShowButton :Boolean = this.showResurrectButton;
        if (_resurrectButton != null && !shouldShowButton) {
            _resurrectButton.parent.removeChild(_resurrectButton);
            _resurrectButton = null;

        } else if (_resurrectButton == null && shouldShowButton) {
            _resurrectButton = UIBits.createButton("Resurrect", 2.5);
            _resurrectButton.x = (Constants.SCREEN_SIZE.x - _resurrectButton.width) * 0.5;
            _resurrectButton.y = (Constants.SCREEN_SIZE.y - _resurrectButton.height - 70);
            GameContext.dashboardLayer.addChild(_resurrectButton);

            this.registerEventListener(_resurrectButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    GameContext.gameMode.resurrectLocalPlayer();
                });
        }
    }

    protected function get showingDeathPanel () :Boolean
    {
        return _deathPanel.visible;
    }

    protected function get showResurrectButton () :Boolean
    {
        return (showingDeathPanel &&
            GameContext.canResurrect &&
            GameContext.localPlayerInfo.canResurrect);
    }

    protected function updateResourceMeters () :void
    {
        for (var resType :int = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            this.updateResourceMeter(resType);
        }
    }

    protected function updateResourceMeter (resType :int) :void
    {
        var resAmount :int = GameContext.localPlayerInfo.getResourceAmount(resType);

        // only update if the resource amount has changed
        var oldResAmount :int = _oldResourceAmounts[resType];
        if (resAmount == oldResAmount) {
            return;
        }

        _oldResourceAmounts[resType] = resAmount;

        var textObj :SimpleSceneObject = _resourceTextObjs[resType];
        var textField :TextField = TextField(textObj.displayObject);
        textField.text = String(resAmount);

        var puzzleFrame :MovieClip = this.puzzleFrame;
        var resourceBarParent :Sprite = _resourceBars[resType];

        if (null == resourceBarParent) {
            resourceBarParent = SpriteUtil.createSprite();
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
                1 + (RESOURCE_METER_WIDTH * (resAmount / GameContext.localPlayerInfo.maxResourceAmount)),
                RESOURCE_METER_HEIGHT);
            g.endFill();
        }

        if (resAmount != 0 && oldResAmount == 0) {
            textObj.visible = true;
            textObj.removeAllTasks();
        } else if(resAmount == 0 && oldResAmount != 0) {
            var blinkTask :RepeatingTask = new RepeatingTask();
            blinkTask.addTask(new VisibleTask(false));
            blinkTask.addTask(new TimedTask(0.25));
            blinkTask.addTask(new VisibleTask(true));
            blinkTask.addTask(new TimedTask(0.25));
            textObj.addTask(blinkTask);
        }
    }

    protected var _movie :MovieClip;
    protected var _deathPanel :MovieClip;
    protected var _shuffleMovie :MovieClip;
    protected var _resourceTextObjs :Array = [];
    protected var _resourceBars :Array = [];
    protected var _oldResourceAmounts :Array = [];
    protected var _spellSlots :Array = []; // of Booleans
    protected var _playerStatusViews :Array = [];
    protected var _resurrectButton :SimpleButton;

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

    protected static const VIEW_MOVE_TIME :Number = 0.5;
}

}

import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.text.TextField;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.resource.*;
import flash.display.InteractiveObject;

/** Currently unused */
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
