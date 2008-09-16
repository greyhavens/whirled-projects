package simon {

import com.whirled.contrib.simplegame.tasks.*;

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;

public class LocalRainbowController extends AbstractRainbowController
{
    public function LocalRainbowController (playerId :int)
    {
        super(playerId);
    }

    override protected function playRainbowLoop () :void
    {
        super.playRainbowLoop();

        // play an animation of the current pattern
        var playPatternTask :SerialTask = new SerialTask();

        for each (var noteIndex :int in SimonMain.model.curState.pattern) {
            playPatternTask.addTask(new FunctionTask(this.createPlayNoteAnimationFunction(noteIndex)));
            playPatternTask.addTask(new TimedTask(PLAYBACK_ANIMATION_NOTE_DELAY));
        }

        playPatternTask.addTask(new FunctionTask(setupRainbowForPlayerInput));

        this.addTask(playPatternTask);
    }

    protected function createPlayNoteAnimationFunction (noteIndex :int) :Function
    {
        return function () :void {
            playNoteAnimation(noteIndex, DEFAULT_SPARKLE_LOCS[noteIndex], true);
        }
    }

    protected function setupRainbowForPlayerInput () :void
    {
        var i :int = 0;
        for each (var band :MovieClip in _rainbowBands) {
            this.createBandMouseHandlers(band, i++);
        }
    }

    protected function createBandMouseHandlers (band :MovieClip, noteIndex :int) :void
    {
        band.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
        band.addEventListener(MouseEvent.ROLL_OVER, rolloverHandler);
        band.addEventListener(MouseEvent.ROLL_OUT, rolloutHandler);

        var thisObject :LocalRainbowController = this;

        function clickHandler (...ignored) :void {
            thisObject.nextNoteSelected(noteIndex, new Point(_curAnim.mouseX, _curAnim.mouseY));
        }

        function rolloverHandler (...ignored) :void {
            if (!_finalNotePlayed && band != _hilitedBand) {

                if (null != _hilitedBand) {
                    _hilitedBand.filters = [ g_lightenFilter ];
                }

                _hilitedBand = band;
                _hilitedBand.filters = [];
            }
        }

        function rolloutHandler (...ignored) :void {
            if (!_finalNotePlayed && band == _hilitedBand) {
                _hilitedBand.filters = [ g_lightenFilter ];
                _hilitedBand = null;
            }
        }
    }

    override protected function nextNoteSelected (noteIndex :int, clickLoc :Point) :void
    {
        super.nextNoteSelected(noteIndex, clickLoc);

        // show an animation on the player avatar
        AvatarController.instance.playAvatarAction("Jump");

        // send a message to everyone else
        SimonMain.model.sendRainbowClickedMessage(noteIndex);
    }

    protected var _hilitedBand :MovieClip;

    protected static const PLAYBACK_ANIMATION_NOTE_DELAY :Number = Constants.PLAYER_TIME_PER_NOTE_S;
}

}
