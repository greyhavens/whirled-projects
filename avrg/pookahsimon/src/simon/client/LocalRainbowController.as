package simon.client {

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;

import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;

import simon.data.Constants;

public class LocalRainbowController extends AbstractRainbowController
{
    public function LocalRainbowController (playerId :int)
    {
        super(playerId);
    }

    override protected function playRainbowLoop () :void
    {
        super.playRainbowLoop();
        noteCompleted();
    }

    protected function noteCompleted() :void
    {
        if (++_replayNote == _remainingPattern.length) {
            _replayNote = -1;
            setupRainbowForPlayerInput();
            return;
        }

        var noteIdx :int = _remainingPattern[_replayNote];
        playNoteAnimation(noteIdx, DEFAULT_SPARKLE_LOCS[noteIdx], true, noteCompleted);
    }

    protected function setupRainbowForPlayerInput () :void
    {
        var i :int = 0;
        for each (var band :MovieClip in _rainbowBands) {
            this.createBandMouseHandlers(band, i++);
        }
        SimonMain.model.replayFinished();
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
    protected var _replayNote :int = -1;

    protected static const PLAYBACK_ANIMATION_NOTE_DELAY :Number = Constants.PLAYER_TIME_PER_NOTE_S;
}

}
