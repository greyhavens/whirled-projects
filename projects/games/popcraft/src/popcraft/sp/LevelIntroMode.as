package popcraft.sp {

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
import popcraft.battle.view.UnitAnimationFactory;
import popcraft.data.SpellData;
import popcraft.data.UnitData;

public class LevelIntroMode extends AppMode
{
    override protected function setup () :void
    {
        // draw dim background
        var dimness :Shape = new Shape();
        var g :Graphics = dimness.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        this.modeSprite.addChild(dimness);

        var movie :MovieClip = SwfResource.instantiateMovieClip("manual", "manual");
        movie.x = Constants.SCREEN_SIZE.x * 0.5;
        movie.y = Constants.SCREEN_SIZE.y * 1.5;
        this.modeSprite.addChild(movie);

        // animate the book in
        _movieObj = new SimpleSceneObject(movie);
        this.addObject(_movieObj);

        var animateTask :SerialTask = new SerialTask();
        animateTask.addTask(LocationTask.CreateEaseIn(Constants.SCREEN_SIZE.x * 0.5, Constants.SCREEN_SIZE.y * 0.5, 0.7));
        animateTask.addTask(new GoToFrameTask("open"));
        animateTask.addTask(new WaitForFrameTask("opened"));

        _movieObj.addTask(animateTask);

        this.doNextPhase();

        this.modeSprite.visible = false;

        StageQualityManager.pushStageQuality(StageQuality.HIGH);
    }

    override protected function destroy () :void
    {
        super.destroy();

        StageQualityManager.popStageQuality();
    }

    protected function hasPhase (phaseNum :int) :Boolean
    {
        switch (phaseNum) {
        case PHASE_CREATUREINTRO: return GameContext.spLevel.newCreatureType >= 0;
        case PHASE_SPELLINTRO: return GameContext.spLevel.newSpellType >= 0;
        case PHASE_LEVELINTRO: return true;
        }

        return false;
    }

    protected function getNextPhase (phaseNum :int) :int
    {
        while (++phaseNum < PHASE__LIMIT && !this.hasPhase(phaseNum)) {
            // cycle phases until we get to one we have or run out
        }

        return phaseNum;
    }

    protected function doNextPhase () :Boolean
    {
       _phase = this.getNextPhase(_phase);

        switch (_phase) {
        case PHASE_CREATUREINTRO:
            var newCreatureType :int = GameContext.spLevel.newCreatureType;
            var creatureData :UnitData = GameContext.gameData.units[newCreatureType];
            var creatureAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(
                creatureData, GameContext.localPlayerInfo.playerColor, "walk_SW");
            if (null == creatureAnim) {
                creatureAnim = UnitAnimationFactory.instantiateUnitAnimation(
                    creatureData, GameContext.localPlayerInfo.playerColor, "stand_SW");
            }
            this.showPage(
                TYPE_PAGE,
                "The " + creatureData.displayName,
                creatureData.introText,
                creatureData.introText2,
                creatureAnim);
            break;

        case PHASE_SPELLINTRO:
            var newSpellType :int = GameContext.spLevel.newSpellType;
            var spellData :SpellData = GameContext.gameData.spells[newSpellType];
            var spellAnim :MovieClip = SwfResource.instantiateMovieClip("dashboard", spellData.iconName);
            this.showPage(
                TYPE_PAGE,
                "Infusion: " + spellData.displayName,
                spellData.introText,
                spellData.introText,
                spellAnim);
            break;

        case PHASE_LEVELINTRO:
            this.showPage(
                TYPE_NOTE,
                AppContext.levelMgr.curLevelName,
                GameContext.spLevel.introText,
                GameContext.spLevel.introText2,
                null);
            break;
        }

        return true;
    }

    protected function showPage (pageType :String, objectName :String, leftText :String, rightText :String, anim :MovieClip) :void
    {
        var isNote :Boolean = pageType == "note";

        var movie :MovieClip = _movieObj.displayObject as MovieClip;
        var leftPage :MovieClip = movie["pageL"];
        var rightPage :MovieClip = movie["pageR"];
        var leftNote :MovieClip = leftPage["note"];
        var rightNote :MovieClip = rightPage["note"];

        leftNote.visible = isNote;
        rightNote.visible = isNote;

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
        _okButton.addEventListener(MouseEvent.CLICK, okClicked);

        // page number
        _pageNum = Rand.nextIntRange(_pageNum + 10, _pageNum + 1000, Rand.STREAM_COSMETIC);
        TextField(leftPage["pagenum"]).text = String(_pageNum);

        // object name
        var titleText :TextField = (isNote ? rightNote["note_title"] : rightPage["title"]);
        if (null != titleText) {
            titleText.text = objectName;
        }

        // intro texts
        var leftPageText :TextField = (isNote ? leftNote["note_text"] : leftPage["text"]);
        if (null != leftPageText) {
            leftPageText.text = leftText;
        }

        var rightPageText :TextField = (isNote ? rightNote["note_text"] : rightPage["text"]);
        if (null != rightPageText) {
            rightPageText.text = rightText;
        }
    }

    protected function okClicked (...ignored) :void
    {
        // prevent multiple clicks
        _okButton.removeEventListener(MouseEvent.CLICK, okClicked);

        var movieTask :SerialTask = new SerialTask();
        if (this.getNextPhase(_phase) < PHASE__LIMIT) {
            // animate the page turn
            movieTask.addTask(new PlaySoundTask("sfx_pageturn"));
            movieTask.addTask(new GoToFrameTask("turn"));
            movieTask.addTask(new WaitForFrameTask("swap"));
            movieTask.addTask(new FunctionTask(doNextPhase));
        } else {
            // animate the book closing and pop the mode
            movieTask.addTask(new PlaySoundTask("sfx_bookclose"));
            movieTask.addTask(new GoToFrameTask("close"));
            movieTask.addTask(new WaitForFrameTask("closed"));
            movieTask.addTask(LocationTask.CreateEaseIn(Constants.SCREEN_SIZE.x * 0.5, Constants.SCREEN_SIZE.y * 1.5, 0.7));
            movieTask.addTask(new FunctionTask(AppContext.mainLoop.popMode));
        }

        _movieObj.removeAllTasks();
        _movieObj.addTask(movieTask);
    }

    override protected function enter () :void
    {
        this.modeSprite.visible = true;
    }

    override protected function exit () :void
    {
        this.modeSprite.visible = false;
    }

    protected var _movieObj :SimpleSceneObject;
    protected var _okButton :SimpleButton;
    protected var _phase :int = -1;
    protected var _pageNum :int;

    protected static const TYPE_PAGE :String = "page";
    protected static const TYPE_NOTE :String = "note";

    protected static const PHASE_CREATUREINTRO :int = 0;
    protected static const PHASE_SPELLINTRO :int = 1;
    protected static const PHASE_LEVELINTRO :int = 2;
    protected static const PHASE__LIMIT :int = 3;
}

}
