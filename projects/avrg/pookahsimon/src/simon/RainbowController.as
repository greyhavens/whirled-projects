package simon {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.AVRGameAvatar;
import com.whirled.contrib.ColorMatrix;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.text.TextField;
import flash.utils.Timer;

public class RainbowController
{
    public function RainbowController (playerId :int)
    {
        if (null == g_lightenMatrix) {
            g_lightenMatrix = new ColorMatrix();
            g_lightenMatrix.tint(0xFFFFFF, 0.33);
        }

        if (null == g_darkenMatrix) {
            g_darkenMatrix = new ColorMatrix();
            g_darkenMatrix.tint(0x000000, 0.33);
        }

        _playerId = playerId;
        _remainingPattern = SimonMain.model.curState.pattern.slice();

        _noteAnimationTimer = new Timer(NOTE_TIMER_LENGTH_MS, 1);
        _noteAnimationTimer.addEventListener(TimerEvent.TIMER, noteAnimationTimerExpired);

        SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_RAINBOW_SELECTION, handleNextSelectionEvent);

        this.playRainbowAnimation("rainbow_in", playRainbowLoop);
    }

    public function destroy () :void
    {
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEXT_RAINBOW_SELECTION, handleNextSelectionEvent);
        _noteAnimationTimer.removeEventListener(TimerEvent.TIMER, noteAnimationTimerExpired);

        this.stopRainbowAnimation();
        this.stopNoteAnimation();
    }

    protected function playRainbowAnimation (animName :String, completionCallback :Function) :void
    {
        this.stopRainbowAnimation();

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

    protected function stopRainbowAnimation () :void
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
        this.playRainbowAnimation("rainbow_loop", null);

        // setup
        var i :int = 0;
        for each (var bandName :String in RAINBOW_BAND_NAMES) {
            var band :MovieClip = (_curAnim["inst_rainbow"])[bandName];
            band.filters = [ g_lightenMatrix.createFilter() ];

            if (this.isControlledLocally) {
                this.createBandMouseHandlers(band, i++);
            }

            _rainbowBands.push(band);
        }

        var playerText :TextField = _curAnim["player"];
        playerText.text = SimonMain.getPlayerName(_playerId);

    }

    protected function handleNextSelectionEvent (e :SharedStateChangedEvent) :void
    {
        // if this rainbow is controlled locally, ignore "next selection" events,
        // as the associated animation will have already been played

        if (!this.isControlledLocally)  {
            var noteIndex :int = e.data as int;
            var clickLoc :Point = DEFAULT_SPARKLE_LOCS[noteIndex];
            this.nextNoteSelected(noteIndex, clickLoc, false);
        }
    }

    protected function createBandMouseHandlers (band :MovieClip, noteIndex :int) :void
    {
        // this function is only called if the rainbow belongs to the local player

        band.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
        band.addEventListener(MouseEvent.ROLL_OVER, rolloverHandler);
        band.addEventListener(MouseEvent.ROLL_OUT, rolloutHandler);

        var thisObject :RainbowController = this;

        function clickHandler (e :MouseEvent) :void {
            thisObject.nextNoteSelected(noteIndex, new Point(_curAnim.mouseX, _curAnim.mouseY), true);
        }

        function rolloverHandler (e :MouseEvent) :void {
            if (!_finalNotePlayed && band != _hilitedBand) {

                if (null != _hilitedBand) {
                    _hilitedBand.filters = [ g_lightenMatrix.createFilter() ];
                }

                _hilitedBand = band;
                _hilitedBand.filters = [];
            }
        }

        function rolloutHandler (e :MouseEvent) :void {
            if (!_finalNotePlayed && band == _hilitedBand) {
                _hilitedBand.filters = [ g_lightenMatrix.createFilter() ];
                _hilitedBand = null;
            }
        }
    }

    protected function nextNoteSelected (noteIndex :int, clickLoc :Point, sendNextNoteMessage :Boolean) :void
    {
        var success :Boolean;

        if (0 == _remainingPattern.length) {
            // the player successfully completed the pattern, and has added
            // a new note to the end
            success = true;
            _finalNotePlayed = true;

        } else if (noteIndex == _remainingPattern[0]) {
            // the player clicked correctly
            success = true;

            _remainingPattern.shift();

        } else {
            // failure!
            success = false;
            _finalNotePlayed = true;

        }

        if (sendNextNoteMessage) {
            // send a message to everyone else
            SimonMain.model.sendRainbowClickedMessage(noteIndex);
        }

        if (_finalNotePlayed) {
            _success = success;
            _finalNoteIndex = noteIndex;
        }

        this.playNoteAnimation(noteIndex, clickLoc, success);

    }

    protected function reportSuccessOrFailure () :void
    {
        // tell the controller we need a state change
        if (_success) {
            SimonMain.controller.currentPlayerTurnSuccess(_finalNoteIndex);
        } else {
            SimonMain.controller.currentPlayerTurnFailure();
        }
    }

    protected function noteAnimationTimerExpired (e :Event) :void
    {
        this.stopNoteAnimation();

        // if the final note was just played, play the outro animation and report success or failure
        if (_finalNotePlayed) {
            this.playRainbowAnimation("rainbow_out", reportSuccessOrFailure);
        }
    }

    protected function playNoteAnimation (noteIndex :int, clickLoc :Point, success :Boolean) :void
    {
        this.stopNoteAnimation();

        if (noteIndex >= 0 && noteIndex < _rainbowBands.length) {
            _noteAnimationIndex = noteIndex;

            var band :MovieClip = _rainbowBands[_noteAnimationIndex];

            if (success) {
                // play a happy sound
                Sound(new RAINBOW_SOUNDS[noteIndex]).play();

                // play an animation on the band
                band.play();

                // create and play a sparkle animation
                var sparkleClass :Class = SimonMain.resourcesDomain.getDefinition("sparkle") as Class;
                var sparkle :MovieClip = new sparkleClass();

                sparkle.x = clickLoc.x;
                sparkle.y = clickLoc.y;

                _curAnim.addChild(sparkle);
                this.createSparkleCleanupHandler(sparkle);
            } else {
                // you screwed up

                var failSoundChannel :SoundChannel = Sound(new Resources.SFX_FAIL).play();
                failSoundChannel.soundTransform = new SoundTransform(0.5); // this sound is unusually loud

                Sound(new RAINBOW_SOUNDS[noteIndex]).play();

                band.filters = [ g_darkenMatrix.createFilter() ];
            }

            _noteAnimationTimer.reset();
            _noteAnimationTimer.start();
        }

        // disable mouse events while the note animation is playing
        if (null != _curAnim) {
            _curAnim.mouseChildren = false;
        }
    }

    protected function createSparkleCleanupHandler (sparkle :MovieClip) :void
    {
        var animHandler :AnimationHandler = new AnimationHandler(sparkle, "end", cleanupSparkle);
        _sparkleAnimHandlers.push(animHandler);

        function cleanupSparkle () :void
        {
            sparkle.parent.removeChild(sparkle);
            ArrayUtil.removeFirst(_sparkleAnimHandlers, animHandler);
        }
    }

    protected function stopNoteAnimation () :void
    {
        _noteAnimationTimer.stop();

        if (_noteAnimationIndex >= 0) {
            _noteAnimationIndex = -1;
        }

        // re-enable mouse events at note animation completion
        if (null != _curAnim) {
            _curAnim.mouseChildren = true;
        }
    }

    protected function getScreenLoc () :Point
    {
        var p :Point;

        var avatarInfo :AVRGameAvatar = (SimonMain.control.isConnected() ? SimonMain.control.getAvatarInfo(_playerId) : null);
        if (null != avatarInfo) {
            p = SimonMain.control.locationToStage(avatarInfo.x, avatarInfo.y, avatarInfo.z);
            p.y -= avatarInfo.stageBounds.height;
        }

        return (null != p ? p : new Point(150, 300));
    }

    public function get isControlledLocally () :Boolean
    {
        return (_playerId == SimonMain.localPlayerId);
    }

    protected var _finalNotePlayed :Boolean;
    protected var _success :Boolean;
    protected var _finalNoteIndex :int;

    protected var _playerId :int;
    protected var _animHandler :AnimationHandler;
    protected var _curAnim :MovieClip;
    protected var _remainingPattern :Array;

    protected var _hilitedBand :MovieClip;

    protected var _sparkleAnimHandlers :Array = [];

    protected var _noteAnimationTimer :Timer;
    protected var _noteAnimationIndex :int = -1;

    protected var _rainbowBands :Array = [];

    protected var log :Log = Log.getLog(this);

    protected static const RAINBOW_BAND_NAMES :Array = [
        "inst_r",
        "inst_o",
        "inst_y",
        "inst_g",
        "inst_b",
        "inst_i",
        "inst_v",
    ];

    protected static const RAINBOW_SOUNDS :Array = [
        Resources.SFX_RED,
        Resources.SFX_ORANGE,
        Resources.SFX_YELLOW,
        Resources.SFX_GREEN,
        Resources.SFX_BLUE,
        Resources.SFX_INDIGO,
        Resources.SFX_VIOLET,
    ];

    protected static const DEFAULT_SPARKLE_LOCS :Array = [
        new Point(-54, -215),
        new Point(-29, -214),
        new Point(-5, -214),
        new Point(14, -213),
        new Point(35, -213),
        new Point(65, -208),
        new Point(83, -208),
    ];

    protected static var g_lightenMatrix :ColorMatrix;
    protected static var g_darkenMatrix :ColorMatrix;

    protected static const NOTE_TIMER_LENGTH_MS :Number = 0.75 * 1000;
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
