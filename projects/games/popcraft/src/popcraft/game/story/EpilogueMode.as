package popcraft.game.story {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.StageQuality;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.data.LevelData;
import popcraft.ui.UIBits;

public class EpilogueMode extends TransitionMode
{
    public static const TRANSITION_LEVELSELECT :int = 0;
    public static const TRANSITION_LEVELOUTRO :int = 1;

    public function EpilogueMode (nextTransition :int, level :LevelData = null)
    {
        _nextTransition = nextTransition;
        _level = level;
    }

    override protected function setup () :void
    {
        // play some music
        _musicChannel = ClientCtx.audio.playSound(Resources.getMusic("mus_night"), null, -1);

        var movie :MovieClip = SwfResource.getSwfDisplayRoot(ClientCtx.rsrcs, "epilogue") as MovieClip;
        movie.gotoAndPlay(0);
        var movieObj :SimpleSceneObject = new SimpleSceneObject(movie);
        var movieTask :SerialTask = new SerialTask();
        movieTask.addTask(new WaitForFrameTask("end"));
        movieTask.addTask(new FunctionTask(endEpilogue));
        movieObj.addTask(movieTask);
        addObject(movieObj, _modeLayer);

        // skip button, to end the sequence
        _skipButton = UIBits.createButton("Skip", 1.2);
        _skipButton.x = Constants.SCREEN_SIZE.x - _skipButton.width - 15;
        _skipButton.y = Constants.SCREEN_SIZE.y - _skipButton.height - 15;

        _modeLayer.addChild(_skipButton);

        registerOneShotCallback(_skipButton, MouseEvent.CLICK, onSkipClicked);
    }

    override protected function enter () :void
    {
        super.enter();
        StageQualityManager.pushStageQuality(StageQuality.HIGH);
    }

    override protected function exit () :void
    {
        super.exit();
        StageQualityManager.popStageQuality();
    }

    protected function onSkipClicked (...ignored) :void
    {
        endEpilogue();
    }

    protected function endEpilogue () :void
    {
        _musicChannel.audioControls.fadeOut(DEFAULT_FADE_TIME).stopAfter(DEFAULT_FADE_TIME);
        _skipButton.parent.removeChild(_skipButton);

        // fade out and pop mode
        switch (_nextTransition) {
        case TRANSITION_LEVELSELECT:
            fadeOut(function () :void {
                LevelSelectMode.create();
            });
            break;

        case TRANSITION_LEVELOUTRO:
            fadeOutToMode(new LevelOutroMode(_level));
            break;
        }
    }

    protected var _skipButton :SimpleButton;
    protected var _musicChannel :AudioChannel;
    protected var _nextTransition :int;
    protected var _level :LevelData;

    protected static const SCREEN_FADE_TIME :Number = 1.5;
}

}
