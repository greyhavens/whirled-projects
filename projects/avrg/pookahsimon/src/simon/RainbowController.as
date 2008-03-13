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
        _playerId = playerId;
        _remainingPattern = SimonMain.model.curState.pattern.slice();

        this.playAnimation("rainbow_in", playRainbowLoop);
    }

    protected function playAnimation (animName :String, completionCallback :Function) :void
    {
        if (null != _curAnim) {
            SimonMain.sprite.removeChild(_curAnim);
            _curAnim = null;
        }

        if (null != _animHandler) {
            _animHandler.destroy();
            _animHandler = null;
        }

        var animClass :Class = SimonMain.resourcesDomain.getDefinition(animName) as Class;
        _curAnim = new animClass();

        var loc :Point = this.getLoc();
        _curAnim.x = loc.x;
        _curAnim.y = loc.y;

        SimonMain.sprite.addChild(_curAnim);

        if (null != completionCallback) {
            _animHandler = new AnimationHandler(_curAnim, "end", completionCallback);
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

    protected function createBandClickHandler (band :MovieClip, bandIndex :int) :void
    {
        // this function is only called if the rainbow belongs to the local player

        band.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);

        function clickHandler (e :MouseEvent) :void
        {
            if (0 == _remainingPattern.length) {
                // the player successfully completed the pattern, and has added
                // a new note to the end
                log.info(bandIndex + " success!");

            } else if (bandIndex == _remainingPattern[0]) {
                // the player clicked correctly
                log.info(bandIndex + " clicked correctly");
                _remainingPattern.shift();

            } else {
                // failure!
                log.info(bandIndex + " fail!");

            }
        }
    }

    protected function getLoc () :Point
    {
        var avatarInfo :AVRGameAvatar = (SimonMain.control.isConnected() ? SimonMain.control.getAvatarInfo(_playerId) : null);

        return (null != avatarInfo ? new Point(avatarInfo.x, avatarInfo.y) : new Point(150, 500));
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