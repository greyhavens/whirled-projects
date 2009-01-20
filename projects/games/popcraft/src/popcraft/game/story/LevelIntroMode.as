package popcraft.game.story {

import com.threerings.flash.TextFieldUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.StageQuality;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.game.*;
import popcraft.battle.view.CreatureAnimFactory;
import popcraft.data.LevelData;
import popcraft.data.SpellData;
import popcraft.data.UnitData;

public class LevelIntroMode extends AppMode
{
    public function LevelIntroMode (level :LevelData)
    {
        _level = level;
    }

    override protected function setup () :void
    {
        // draw dim background
        var dimness :Shape = new Shape();
        var g :Graphics = dimness.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        this.modeSprite.addChild(dimness);

        // create "manual_front"
        var manualFront :MovieClip = SwfResource.instantiateMovieClip("manual", "manual_front");
        var manualFrontObj :SimpleSceneObject = new SimpleSceneObject(manualFront);
        manualFrontObj.x = Constants.SCREEN_SIZE.x * 0.5;
        manualFrontObj.y = Constants.SCREEN_SIZE.y * 1.5;

        // hide some stuff we don't need
        var cover :MovieClip = manualFront["cover"];
        var graduate :MovieClip = cover["graduate"];
        graduate.visible = false;

        // animate manual_front in from the bottom of the screen, play its open animation,
        // then swap it out for the real manual object
        var manualFrontTask :SerialTask = new SerialTask();
        manualFrontTask.addTask(LocationTask.CreateEaseOut(
            Constants.SCREEN_SIZE.x * 0.5, Constants.SCREEN_SIZE.y * 0.5, 0.7));
        manualFrontTask.addTask(new TimedTask(
            ClientContext.levelMgr.curLevelIndex == 0 ? LEVEL_1_TURN_PAUSE : DEFAULT_TURN_PAUSE));
        manualFrontTask.addTask(new GoToFrameTask("turn"));
        manualFrontTask.addTask(new WaitForFrameTask("edge"));
        manualFrontTask.addTask(new PlaySoundTask("sfx_bookopenclose"));
        manualFrontTask.addTask(new FunctionTask(swapInManual));
        manualFrontTask.addTask(new SelfDestructTask());

        manualFrontObj.addTask(manualFrontTask);

        addObject(manualFrontObj, this.modeSprite);

        this.modeSprite.visible = false;
    }

    override protected function enter () :void
    {
        super.enter();
        StageQualityManager.pushStageQuality(StageQuality.HIGH);
        this.modeSprite.visible = true;
    }

    override protected function exit () :void
    {
        super.exit();
        StageQualityManager.popStageQuality();
        this.modeSprite.visible = false;
    }

    protected function swapInManual () :void
    {
        // animate the book open
        var manual :MovieClip = SwfResource.instantiateMovieClip("manual", "manual");
        manual.gotoAndPlay("open");

        _manualObj = new SimpleSceneObject(manual);
        _manualObj.x = Constants.SCREEN_SIZE.x * 0.5;
        _manualObj.y = Constants.SCREEN_SIZE.y * 0.5;
        addObject(_manualObj, this.modeSprite);

        doNextPhase();
    }

    protected function hasPhase (phaseNum :int) :Boolean
    {
        switch (phaseNum) {
        case PHASE_CREATUREINTRO: return _level.newCreatureType >= 0;
        case PHASE_SPELLINTRO: return _level.newSpellType >= 0;
        case PHASE_LEVELINTRO: return true;
        }

        return false;
    }

    protected function getNextPhase (phaseNum :int) :int
    {
        while (++phaseNum < PHASE__LIMIT && !hasPhase(phaseNum)) {
            // cycle phases until we get to one we have or run out
        }

        return phaseNum;
    }

    protected function doNextPhase () :Boolean
    {
       _phase = getNextPhase(_phase);

        switch (_phase) {
        case PHASE_CREATUREINTRO:
            var newCreatureType :int = _level.newCreatureType;
            var creatureData :UnitData = GameContext.gameData.units[newCreatureType];
            var creatureAnim :MovieClip = CreatureAnimFactory.instantiateUnitAnimation(
                newCreatureType, GameContext.localPlayerInfo.color, "walk_SW");
            if (null == creatureAnim) {
                creatureAnim = CreatureAnimFactory.instantiateUnitAnimation(
                    newCreatureType, GameContext.localPlayerInfo.color, "stand_SW");
            }
            showPage(
                TYPE_PAGE,
                "",
                "The " + creatureData.displayName,
                creatureData.introText,
                creatureData.introText2,
                creatureAnim);
            break;

        case PHASE_SPELLINTRO:
            var newSpellType :int = _level.newSpellType;
            var spellData :SpellData = GameContext.gameData.spells[newSpellType];
            var spellAnim :MovieClip = SwfResource.instantiateMovieClip("dashboard",
                spellData.iconName);
            showPage(
                TYPE_PAGE,
                "",
                "Infusion: " + spellData.displayName,
                "",
                spellData.introText,
                spellAnim,
                true);
            break;

        case PHASE_LEVELINTRO:
            var expertCompletionDays :int = _level.expertCompletionDays;
            var levelDescription :String =
                _level.introText2 +
                "\n\n(Complete the level in " +
                String(expertCompletionDays) +
                (expertCompletionDays == 1 ? " day" : " days") +
                " for an expert score.)";

            showPage(
                TYPE_NOTE,
                "Chapter " + String(ClientContext.levelMgr.curLevelIndex + 1),
                ClientContext.levelMgr.curLevelName,
                _level.introText,
                levelDescription,
                null);
            break;
        }

        return true;
    }

    protected function showPage (pageType :String, leftTitle :String, rightTitle :String,
        leftText :String, rightText :String, anim :MovieClip, showLadyfingers :Boolean = false)
        :void
    {
        var isNote :Boolean = pageType == "note";

        var movie :MovieClip = _manualObj.displayObject as MovieClip;
        var leftPage :MovieClip = movie["pageL"];
        var rightPage :MovieClip = movie["pageR"];
        var leftNote :MovieClip = leftPage["note"];
        var rightNote :MovieClip = rightPage["note"];

        // hide the upsell animations
        MovieClip(leftPage["upsell_L"]).visible = false;
        MovieClip(rightPage["upsell_R"]).visible = false;

        leftNote.visible = isNote;
        rightNote.visible = isNote;

        if (!isNote) {
            var ladyfingers :MovieClip = leftPage["ladyfingers_image"];
            ladyfingers.visible = showLadyfingers;
        }

        var animParent :MovieClip = rightPage["image"];
        if (null != animParent) {
            if (animParent.numChildren > 0) {
                animParent.removeChildAt(0);
            }

            if (null != anim) {
                animParent.addChild(anim);
            }
        }

        // ok button
        _okButton = rightPage["ok"];
        registerListener(_okButton, MouseEvent.CLICK, okClicked);

        // page number
        _pageNum = Rand.nextIntRange(_pageNum + 10, _pageNum + 1000, Rand.STREAM_COSMETIC);
        TextField(leftPage["pagenum"]).text = String(_pageNum);

        // left title
        var leftTitleText :TextField = (isNote ? leftNote["note_title"] : null);
        if (null != leftTitleText) {
            leftTitleText.text = leftTitle;
        }

        // right title
        var rightTitleText :TextField = (isNote ? rightNote["note_title"] : rightPage["title"]);
        if (null != rightTitleText) {
            rightTitleText.text = rightTitle;
        }

        // intro texts
        var leftPageText :TextField = (isNote ? leftNote["note_text"] : leftPage["text"]);
        if (null != leftPageText) {
            if (isNote) {
                // Fix a stupid Flash bug. Apparently letter spacing settings in TextFields created
                // in the FAT don't stick around when that text is dynamically edited.
                TextFieldUtil.updateFormat(leftPageText, { letterSpacing: -2 });
            }
            leftPageText.text = leftText;
        }

        var rightPageText :TextField = (isNote ? rightNote["note_text"] : rightPage["text"]);
        if (null != rightPageText) {
            rightPageText.text = rightText;
        }
    }

    protected function okClicked (...ignored) :void
    {
        var movieTask :SerialTask = new SerialTask();
        if (getNextPhase(_phase) < PHASE__LIMIT) {
            // animate the page turn
            movieTask.addTask(new PlaySoundTask("sfx_pageturn"));
            movieTask.addTask(new GoToFrameTask("turn"));
            movieTask.addTask(new WaitForFrameTask("swap"));
            movieTask.addTask(new FunctionTask(doNextPhase));

        } else {
            // animate the book closing and pop the mode
            movieTask.addTask(new PlaySoundTask("sfx_bookopenclose"));
            movieTask.addTask(new GoToFrameTask("close"));
            movieTask.addTask(new WaitForFrameTask("closed"));
            movieTask.addTask(LocationTask.CreateEaseIn(
                Constants.SCREEN_SIZE.x * 0.5, Constants.SCREEN_SIZE.y * 1.5, 0.7));
            movieTask.addTask(new FunctionTask(ClientContext.mainLoop.popMode));
        }

        _manualObj.removeAllTasks();
        _manualObj.addTask(movieTask);
    }

    protected var _level :LevelData;

    protected var _manualObj :SimpleSceneObject;
    protected var _okButton :SimpleButton;
    protected var _phase :int = -1;
    protected var _pageNum :int;

    protected static const TYPE_PAGE :String = "page";
    protected static const TYPE_NOTE :String = "note";

    protected static const PHASE_CREATUREINTRO :int = 0;
    protected static const PHASE_SPELLINTRO :int = 1;
    protected static const PHASE_LEVELINTRO :int = 2;
    protected static const PHASE__LIMIT :int = 3;

    protected static const LEVEL_1_TURN_PAUSE :Number = 1.5;
    protected static const DEFAULT_TURN_PAUSE :Number = 0.25;
}

}
