package simon {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.AVRGameAvatar;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.text.TextField;

public class RainbowController extends SceneObject
{
    public static const NAME :String = "RainbowController";

    public function RainbowController (playerId :int)
    {
        _playerId = playerId;
        _parentSprite = new Sprite();

        _remainingPattern = SimonMain.model.curState.pattern.slice();
    }

    override public function get displayObject () :DisplayObject
    {
        return _parentSprite;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override protected function addedToDB () :void
    {
        if (null == g_lightenFilter) {
            var lightenMatrix :ColorMatrix = new ColorMatrix();
            lightenMatrix.tint(0xFFFFFF, 0.33);
            g_lightenFilter = lightenMatrix.createFilter();
        }

        if (null == g_darkenFilter) {
            var darkenMatrix :ColorMatrix = new ColorMatrix();
            darkenMatrix.tint(0x000000, 0.33);
            g_darkenFilter = darkenMatrix.createFilter();
        }

        SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_RAINBOW_SELECTION, handleStateChange_NextSelection);
        SimonMain.model.addEventListener(SharedStateChangedEvent.PLAYER_TIMEOUT, handleStateChange_PlayerTimeout);

        this.playRainbowAnimation("rainbow_in", playRainbowLoop);
    }

    override protected function removedFromDB () :void
    {
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEXT_RAINBOW_SELECTION, handleStateChange_NextSelection);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.PLAYER_TIMEOUT, handleStateChange_PlayerTimeout);

        this.stopRainbowAnimation();
        this.stopNoteAnimation();
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        this.updateTimeoutDisplay();
    }

    protected function playRainbowAnimation (animName :String, completionCallback :Function) :void
    {
        this.stopRainbowAnimation();

        _curAnim = Resources.instantiateMovieClip("ui", animName);

        var loc :Point = this.getScreenLoc();
        _curAnim.x = loc.x;
        _curAnim.y = loc.y;

        _parentSprite.addChild(_curAnim);

        if (null != completionCallback) {
            _rainbowAnimHandler = new AnimationHandler(_curAnim, "end", completionCallback);
        }
    }

    protected function stopRainbowAnimation () :void
    {
        if (null != _curAnim) {
            _parentSprite.removeChild(_curAnim);
            _curAnim = null;
        }

        if (null != _rainbowAnimHandler) {
            _rainbowAnimHandler.destroy();
            _rainbowAnimHandler = null;
        }
    }

    protected function playRainbowLoop () :void
    {
        this.playRainbowAnimation("rainbow_loop", null);

        // setup click handlers
        var i :int = 0;
        for each (var bandName :String in RAINBOW_BAND_NAMES) {
            var band :MovieClip = (_curAnim["inst_rainbow"])[bandName];
            band.filters = [ g_lightenFilter ];

            if (this.isControlledLocally) {
                this.createBandMouseHandlers(band, i++);
            }

            _rainbowBands.push(band);
        }

        // show player name
        var playerText :TextField = _curAnim["player"];
        playerText.text = SimonMain.getPlayerName(_playerId);

        // If the rainbow is controlled by this player, show a timer
        // animation. If the player doesn't click a note before the
        // animation completes, they lose. (Hide the animation
        // if it's not our rainbow.)
        if (this.isControlledLocally) {
            this.resetPlayerTimeoutHandler();
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
                new FunctionTask(handleStateChange_PlayerTimeout)));
    }

    protected function stopPlayerTimeoutHandler () :void
    {
        this.removeNamedTasks(PLAYER_TIMEOUT_TASK_NAME);
    }

    protected function handleLocalPlayerTimeout () :void
    {
        SimonMain.model.sendPlayerTimeoutMessage();
        this.gameMode.incrementPlayerTimeoutCount();
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

    protected function handleStateChange_NextSelection (e :SharedStateChangedEvent) :void
    {
        // if this rainbow is controlled locally, ignore "next selection" events,
        // as the associated animation will have already been played

        if (!this.isControlledLocally)  {
            var noteIndex :int = e.data as int;
            var clickLoc :Point = DEFAULT_SPARKLE_LOCS[noteIndex];
            this.nextNoteSelected(noteIndex, clickLoc, false);
        }
    }

    protected function handleStateChange_PlayerTimeout (e :SharedStateChangedEvent) :void
    {
        // called when the player has taken too long to click a note
        this.gameMode.currentPlayerTurnFailure();
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
                    _hilitedBand.filters = [ g_lightenFilter ];
                }

                _hilitedBand = band;
                _hilitedBand.filters = [];
            }
        }

        function rolloutHandler (e :MouseEvent) :void {
            if (!_finalNotePlayed && band == _hilitedBand) {
                _hilitedBand.filters = [ g_lightenFilter ];
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

        // reset the "note time expired" handler every time a new note is played
        if (_finalNotePlayed) {
            this.stopPlayerTimeoutHandler();
        } else if (this.isControlledLocally) {
            this.resetPlayerTimeoutHandler();
        }
    }

    protected function reportSuccessOrFailure () :void
    {
        // tell the controller we need a state change
        if (_success) {
            this.gameMode.currentPlayerTurnSuccess(_finalNoteIndex);
        } else {
            this.gameMode.currentPlayerTurnFailure();
        }
    }

    protected function noteAnimationTimerExpired () :void
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
                var sparkle :MovieClip = Resources.instantiateMovieClip("ui", "sparkle");

                sparkle.x = clickLoc.x;
                sparkle.y = clickLoc.y;

                _curAnim.addChild(sparkle);
                this.createSparkleCleanupHandler(sparkle);

                // show an animation on the player avatar
                if (_playerId == SimonMain.localPlayerId) {
                    AvatarController.instance.playAvatarAction("Jump");
                }

            } else {
                // you screwed up

                var failSoundChannel :SoundChannel = Sound(new Resources.SFX_FAIL).play();
                failSoundChannel.soundTransform = new SoundTransform(0.5); // this sound is unusually loud

                Sound(new RAINBOW_SOUNDS[noteIndex]).play();

                band.filters = [ g_darkenFilter ];
            }

            this.removeNamedTasks(NOTE_ANIMATION_TASK_NAME);
            this.addNamedTask(
                NOTE_ANIMATION_TASK_NAME,
                After(NOTE_ANIMATION_DURATION,
                    new FunctionTask(noteAnimationTimerExpired)));
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
        this.removeNamedTasks(NOTE_ANIMATION_TASK_NAME);

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

            log.info(
                String(SimonMain.localPlayerId) +
                " avatarInfo: (" + avatarInfo.x + "," + avatarInfo.y + "," + avatarInfo.z + ")" +
                " stageLoc: (" + p.x + "," + p.y + ")");

        }

        return (null != p ? p : new Point(150, 300));
    }

    public function get isControlledLocally () :Boolean
    {
        return (_playerId == SimonMain.localPlayerId);
    }

    protected function get gameMode () :GameMode
    {
        return this.db as GameMode;
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

    protected var _parentSprite :Sprite;

    protected var _finalNotePlayed :Boolean;
    protected var _success :Boolean;
    protected var _finalNoteIndex :int;

    protected var _playerId :int;
    protected var _rainbowAnimHandler :AnimationHandler;
    protected var _curAnim :MovieClip;
    protected var _remainingPattern :Array;

    protected var _hilitedBand :MovieClip;

    protected var _sparkleAnimHandlers :Array = [];

    protected var _noteAnimationIndex :int = -1;

    protected var _rainbowBands :Array = [];

    protected var _playerTimeoutCountdown :Object = { value: 0 };

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

    protected static var g_lightenFilter :ColorMatrixFilter;
    protected static var g_darkenFilter :ColorMatrixFilter;

    protected static const NOTE_ANIMATION_DURATION :Number = 0.75;
    protected static const NOTE_ANIMATION_TASK_NAME :String = "NoteAnimationTask";
    protected static const PLAYER_TIMEOUT_TASK_NAME :String = "PlayerTimeoutTask";
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
