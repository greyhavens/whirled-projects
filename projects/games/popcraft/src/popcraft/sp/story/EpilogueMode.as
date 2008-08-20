package popcraft.sp.story {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.StageQuality;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.ui.UIBits;

public class EpilogueMode extends TransitionMode
{
    public static const TRANSITION_LEVELSELECT :int = 0;
    public static const TRANSITION_LEVELOUTRO :int = 1;

    public function EpilogueMode (nextTransition :int)
    {
        _nextTransition = nextTransition;
    }

    override protected function setup () :void
    {
        // play some music
        _musicChannel = AudioManager.instance.playSoundNamed("mus_night", null, -1);

        var movie :MovieClip = SwfResource.getSwfDisplayRoot("epilogue") as MovieClip;
        movie.gotoAndPlay(0);
        var movieObj :SimpleSceneObject = new SimpleSceneObject(movie);
        var movieTask :SerialTask = new SerialTask();
        movieTask.addTask(new WaitForFrameTask("end"));
        movieTask.addTask(new FunctionTask(endEpilogue));
        movieObj.addTask(movieTask);
        this.addObject(movieObj, _modeLayer);

        // skip button, to end the sequence
        _skipButton = UIBits.createButton("Skip", 1.2);
        _skipButton.x = Constants.SCREEN_SIZE.x - _skipButton.width - 15;
        _skipButton.y = Constants.SCREEN_SIZE.y - _skipButton.height - 15;
        _skipButton.addEventListener(MouseEvent.CLICK, onSkipClicked);

        _modeLayer.addChild(_skipButton);
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
        this.endEpilogue();
    }

    protected function endEpilogue () :void
    {
        _musicChannel.audioControls.fadeOut(DEFAULT_FADE_TIME).stopAfter(DEFAULT_FADE_TIME);
        _skipButton.parent.removeChild(_skipButton);

        // fade out and pop mode
        var nextMode :AppMode;
        switch (_nextTransition) {
        case TRANSITION_LEVELSELECT: nextMode = new LevelSelectMode(); break;
        case TRANSITION_LEVELOUTRO: nextMode = new LevelOutroMode(); break;
        }

        this.fadeOutToMode(nextMode);
    }

    protected var _skipButton :SimpleButton;
    protected var _musicChannel :AudioChannel;
    protected var _nextTransition :int;

    protected static const SCREEN_FADE_TIME :Number = 1.5;
}

}
