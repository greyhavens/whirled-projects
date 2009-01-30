package popcraft.game.story {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import popcraft.*;

public class IncidentUpsellMode extends AppMode
{
    override protected function setup () :void
    {
        var movie :MovieClip = ClientCtx.instantiateMovieClip("manual", "manual");
        movie.gotoAndPlay("open");

        var leftPage :MovieClip = movie["pageL"];
        var rightPage :MovieClip = movie["pageR"];
        var leftUpsell :MovieClip = leftPage["upsell_L"];
        var rightUpsell :MovieClip = rightPage["upsell_R"];

        // show the upsell animations
        leftUpsell.visible = true;
        rightUpsell.visible = true;

        // hide everything else
        MovieClip(leftPage["note"]).visible = false;
        MovieClip(rightPage["note"]).visible = false;
        MovieClip(leftPage["ladyfingers_image"]).visible = false;

        _manualObj = new SimpleSceneObject(movie);
        _manualObj.x = Constants.SCREEN_SIZE.x * 0.5;
        _manualObj.y = Constants.SCREEN_SIZE.y * 0.5;
        addObject(_manualObj, this.modeSprite);

        var okButton :SimpleButton = rightPage["ok"];
        registerOneShotCallback(okButton, MouseEvent.CLICK,
            function (...ignored) :void {
                closeMode();
            });

        var unlockButton :SimpleButton = rightUpsell["unlock_button"];
        registerOneShotCallback(unlockButton, MouseEvent.CLICK,
            function (...ignored) :void {
                closeMode();
                ClientCtx.showIncidentGameShop();
            });
    }

    protected function closeMode () :void
    {
        _manualObj.removeAllTasks();
        _manualObj.addTask(new SerialTask(
            new PlaySoundTask("sfx_bookopenclose"),
            new GoToFrameTask("close"),
            new WaitForFrameTask("closed"),
            LocationTask.CreateEaseIn(
                Constants.SCREEN_SIZE.x * 0.5, Constants.SCREEN_SIZE.y * 1.5, 0.7),
            new FunctionTask(ClientCtx.mainLoop.popMode)));
    }

    protected var _manualObj :SimpleSceneObject;
}

}
