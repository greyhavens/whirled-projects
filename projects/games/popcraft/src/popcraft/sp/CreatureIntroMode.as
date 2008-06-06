package popcraft.sp {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.battle.view.UnitAnimationFactory;
import popcraft.data.UnitData;

public class CreatureIntroMode extends AppMode
{
    override protected function setup () :void
    {
        _creatureData = GameContext.gameData.units[GameContext.spLevel.newCreatureType];

        // draw dim background
        var dimness :Shape = new Shape();
        var g :Graphics = dimness.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        this.modeSprite.addChild(dimness);

        var movie :MovieClip = SwfResource.instantiateMovieClip("manual", "manual");
        movie.x = Constants.SCREEN_DIMS.x * 0.5;
        movie.y = Constants.SCREEN_DIMS.y * 1.5;
        this.modeSprite.addChild(movie);

        var leftPage :MovieClip = movie["pageL"];
        var rightPage :MovieClip = movie["pageR"];

        // creature animation
        var creatureAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(
            _creatureData, GameContext.localPlayerInfo.playerColor, "walk_SW");
        if (null == creatureAnim) {
            creatureAnim = UnitAnimationFactory.instantiateUnitAnimation(
                _creatureData, GameContext.localPlayerInfo.playerColor, "stand_SW");
        }

        MovieClip(rightPage["image"]).addChild(creatureAnim);

        // create name
        TextField(rightPage["title"]).text = "The " + _creatureData.displayName;

        // creature intro text
        TextField(leftPage["text"]).text = _creatureData.introText;

        // ok button
        _okButton = rightPage["ok"];
        _okButton.addEventListener(MouseEvent.CLICK, okClicked);

        // animate the book in
        _movieObj = new SimpleSceneObject(movie);
        this.addObject(_movieObj);

        var animateTask :SerialTask = new SerialTask();
        animateTask.addTask(LocationTask.CreateEaseIn(Constants.SCREEN_DIMS.x * 0.5, Constants.SCREEN_DIMS.y * 0.5, 0.7));
        animateTask.addTask(new GoToFrameTask("open"));
        animateTask.addTask(new WaitForFrameTask("opened"));
        animateTask.addTask(new PlaySoundTask("sfx_create_" + _creatureData.name));

        _movieObj.addTask(animateTask);

        this.modeSprite.visible = false;
    }

    protected function okClicked (...ignored) :void
    {
        // prevent multiple clicks
        _okButton.removeEventListener(MouseEvent.CLICK, okClicked);

        _movieObj.removeAllTasks();

        // animate the book out
        var animateTask :SerialTask = new SerialTask();
        animateTask.addTask(new GoToFrameTask("close"));
        animateTask.addTask(new WaitForFrameTask("closed"));
        animateTask.addTask(LocationTask.CreateEaseOut(Constants.SCREEN_DIMS.x * 0.5, Constants.SCREEN_DIMS.y * 1.5, 0.7));
        animateTask.addTask(new FunctionTask(AppContext.mainLoop.popMode));

        _movieObj.addTask(animateTask);
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
    protected var _creatureData :UnitData;
}

}
