package simon {

import com.threerings.util.Log;
import com.whirled.AVRGameAvatar;
import com.whirled.contrib.ColorMatrix;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

public class RainbowController
{
    public function RainbowController (playerId :int)
    {
        log.info("Creating RainbowController for player " + playerId + " (on client " + SimonMain.localPlayerId + ")");

        _playerId = playerId;
        _remainingPattern = SimonMain.model.curState.pattern.slice();

        SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_RAINBOW_SELECTION, handleNextSelectionEvent);

        this.playAnimation("rainbow_in", playRainbowLoop);
    }

    public function destroy () :void
    {
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEXT_RAINBOW_SELECTION, handleNextSelectionEvent);
        this.stopAnimation();
    }

    protected function playAnimation (animName :String, completionCallback :Function) :void
    {
        this.stopAnimation();

        var animClass :Class = SimonMain.resourcesDomain.getDefinition(animName) as Class;
        _curAnim = new animClass();

        var loc :Point = this.getScreenLoc();
        _curAnim.x = loc.x;
        _curAnim.y = loc.y;

        SimonMain.sprite.addChild(_curAnim);

        if (null != completionCallback) {
            _animHandler = new AnimationHandler(_curAnim, "end", completionCallback);
        }

        //log.info("Playing animation " + animName + " at " + loc);
    }

    protected function stopAnimation () :void
    {
        if (null != _curAnim) {
            SimonMain.sprite.removeChild(_curAnim);
            _curAnim = null;
        }

        if (null != _animHandler) {
            _animHandler.destroy();
            _animHandler = null;
        }
    }

    protected function playRainbowLoop () :void
    {
        this.playAnimation("rainbow_loop", null);

        var tintMatrix :ColorMatrix = new ColorMatrix(); // @TODO - do something here

        // setup
        var i :int = 0;
        for each (var bandName :String in RAINBOW_BANDS) {
            var band :MovieClip = (_curAnim["inst_rainbow"])[bandName];
            band.filters = [ tintMatrix.createFilter() ];

            if (this.isControlledLocally) {
                this.createBandClickHandler(band, i++);
            }
        }

    }

    protected function handleNextSelectionEvent (e :SharedStateChangedEvent) :void
    {
        // if this rainbow is controlled locally, ignore "next selection" events,
        // as the associated animation will have already been played

        if (!this.isControlledLocally)  {
            var noteIndex :int = e.data as int;
            this.nextNoteSelected(noteIndex, false);
        }
    }

    protected function createBandClickHandler (band :MovieClip, noteIndex :int) :void
    {
        // this function is only called if the rainbow belongs to the local player

        band.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);

        var thisObject :RainbowController = this;
        function clickHandler (e :MouseEvent) :void {
            thisObject.nextNoteSelected(noteIndex, true);
        }
    }

    protected function nextNoteSelected (noteIndex :int, sendNextNoteMessage :Boolean) :void
    {
        var success :Boolean;
        var playerTurnOver :Boolean;

        if (0 == _remainingPattern.length) {
            // the player successfully completed the pattern, and has added
            // a new note to the end
            success = true;
            playerTurnOver = true;

        } else if (noteIndex == _remainingPattern[0]) {
            // the player clicked correctly
            success = true;
            playerTurnOver = false;

            _remainingPattern.shift();

        } else {
            // failure!
            success = false;
            playerTurnOver = true;

        }

        if (sendNextNoteMessage) {
            // send a message to everyone else
            SimonMain.model.sendRainbowClickedMessage(noteIndex);
        }

        if (playerTurnOver) {
            // tell the controller we need a state change
            if (success) {
                SimonMain.controller.currentPlayerTurnSuccess(noteIndex);
            } else {
                SimonMain.controller.currentPlayerTurnFailure();
            }
        }

        // @TODO - play some animation here
        log.info("note " + noteIndex + " played. " + (success ? "success!" : "fail!"));
        if (playerTurnOver) {
            log.info("end of turn");
        }

    }

    protected function getScreenLoc () :Point
    {
        var p :Point;

        var avatarInfo :AVRGameAvatar = (SimonMain.control.isConnected() ? SimonMain.control.getAvatarInfo(_playerId) : null);
        if (null != avatarInfo) {
            p = SimonMain.control.locationToStage(avatarInfo.x, avatarInfo.y, avatarInfo.z - 0.1);
        }

        return (null != p ? p : new Point(150, 500));
    }

    public function get isControlledLocally () :Boolean
    {
        return (_playerId == SimonMain.localPlayerId);
    }

    protected var _playerId :int;
    protected var _animHandler :AnimationHandler;
    protected var _curAnim :MovieClip;
    protected var _remainingPattern :Array;

    protected var log :Log = Log.getLog(this);

    protected static const RAINBOW_BANDS :Array = [
        "inst_r",
        "inst_o",
        "inst_y",
        "inst_g",
        "inst_b",
        "inst_i",
        "inst_v",
    ];

    protected static const TINT_COLOR :uint = 0xFFFFFF;
    protected static const TINT_AMOUNT :Number = 0.33;
}

}

import flash.display.MovieClip;
import flash.events.Event;

/** Executes a callback when the MovieClip has reached the specified frame name. */
class AnimationHandler
{
    public function AnimationHandler (anim :MovieClip, lastFrameName :String, callback :Function)
    {
        _anim = anim;
        _lastFrameName = lastFrameName;
        _callback = callback;

        _anim.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    public function destroy () :void
    {
        if (null != _anim) {
            _anim.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _anim = null;
        }
    }

    protected function handleEnterFrame (e :Event) :void
    {
        if (_anim.currentLabel == _lastFrameName) {
            this.destroy();
            _callback();
        }
    }

    protected var _anim :MovieClip;
    protected var _lastFrameName :String;
    protected var _callback :Function;
}