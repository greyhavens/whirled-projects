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

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        this.updateTimeoutDisplay();
    }

    protected function updateTimeoutDisplay () :void
    {
        var pieTimer :MovieClip = this.pieTimer;

        if (null != pieTimer) {

            var countdownValue :Number = _playerTimeoutCountdown["value"];

            if (countdownValue <= 0) {
                pieTimer.visible = false;
            } else {
                pieTimer.visible = true;
                var frameNumber :Number = Math.ceil(pieTimer.totalFrames * ((Constants.PLAYER_TIMEOUT_S - countdownValue) / Constants.PLAYER_TIMEOUT_S));
                pieTimer.gotoAndStop(frameNumber);
            }
        }
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
        this.resetPlayerTimeoutHandler();

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

    protected function resetPlayerTimeoutHandler () :void
    {
        _playerTimeoutCountdown["value"] = Constants.PLAYER_TIMEOUT_S;

        this.stopPlayerTimeoutHandler();

        this.addNamedTask(
            PLAYER_TIMEOUT_TASK_NAME,
            new SerialTask(
                new AnimateValueTask(_playerTimeoutCountdown, 0, Constants.PLAYER_TIMEOUT_S),
                new FunctionTask(handleLocalPlayerTimeout)));
    }

    protected function stopPlayerTimeoutHandler () :void
    {
        this.removeNamedTasks(PLAYER_TIMEOUT_TASK_NAME);
    }

    protected function handleLocalPlayerTimeout () :void
    {
        SimonMain.model.sendPlayerTimeoutMessage();
        this.gameMode.incrementPlayerTimeoutCount();
        this.gameMode.currentPlayerTurnFailure();
    }

    override protected function nextNoteSelected (noteIndex :int, clickLoc :Point) :void
    {
        super.nextNoteSelected(noteIndex, clickLoc);

        // show an animation on the player avatar
        AvatarController.instance.playAvatarAction("Jump");

        // reset the "note time expired" handler every time a new note is played
        if (_finalNotePlayed) {
            this.stopPlayerTimeoutHandler();
        } else {
            this.resetPlayerTimeoutHandler();
        }

        // send a message to everyone else
        SimonMain.model.sendRainbowClickedMessage(noteIndex);
    }

    protected function get pieTimer () :MovieClip
    {
        if (null != _curAnim) {
            var noteTimer :MovieClip = _curAnim["note_timer"];
            if (null != noteTimer) {
                return noteTimer["inst_timer_pie"];
            }
        }

        return null;
    }

    protected var _playerTimeoutCountdown :Object = { value: 0 };
    protected var _hilitedBand :MovieClip;

    protected static const PLAYER_TIMEOUT_TASK_NAME :String = "PlayerTimeoutTask";
    protected static const PLAYBACK_ANIMATION_NOTE_DELAY :Number = 0.6;
}

}
