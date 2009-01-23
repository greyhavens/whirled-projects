package simon.client {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.text.TextField;

import com.threerings.util.Log;

import com.whirled.avrg.AVRGameAvatar;

import com.whirled.contrib.ColorMatrix;

import com.whirled.contrib.simplegame.SimObject;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;

import com.whirled.contrib.simplegame.resource.SwfResource;

import com.whirled.contrib.simplegame.tasks.After;
import com.whirled.contrib.simplegame.tasks.AnimateValueTask;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.SelfDestructTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.WaitForFrameTask;

import simon.data.Constants;

public class AbstractRainbowController extends SceneObject
{
    public static const NAME :String = "RainbowController";

    public static function create (playerId :int) :AbstractRainbowController
    {
        if (playerId == SimonMain.localPlayerId) {
            return new LocalRainbowController(playerId);
        } else {
            return new RemoteRainbowController(playerId);
        }
    }

    public function AbstractRainbowController (playerId :int)
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
        super.addedToDB();

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

        SimonMain.model.addEventListener(SimonEvent.START_TIMER, startTimer);

        this.playRainbowAnimation("rainbow_in", playRainbowLoop);
    }

    override protected function removedFromDB () :void
    {
        super.removedFromDB();
        this.stopRainbowAnimation();
        this.stopNoteAnimation();
        SimonMain.model.removeEventListener(SimonEvent.START_TIMER, startTimer);
    }

    protected function playRainbowAnimation (animName :String, completionCallback :Function) :void
    {
        this.stopRainbowAnimation();

        _curAnim = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "ui", animName);

        var loc :Point = this.getScreenLocForRainbowAnimation();
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

        // "lighten" the rainbow bands
        for each (var bandName :String in RAINBOW_BAND_NAMES) {
            var band :MovieClip = (_curAnim["inst_rainbow"])[bandName];
            band.filters = [ g_lightenFilter ];
            _rainbowBands.push(band);
        }

        // show player name
        var playerText :TextField = _curAnim["player"];
        playerText.text = SimonMain.getPlayerName(_playerId);

        if (null != pieTimer) {
            pieTimer.visible = true;
        }
    }

    protected function nextNoteSelected (noteIndex :int, clickLoc :Point) :void
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

        if (_finalNotePlayed) {
            _success = success;
        }

        // reset the "note time expired" handler every time a new note is played
        if (_finalNotePlayed) {
            this.stopPlayerTimeoutHandler();
        } else {
            this.resetPlayerTimeoutHandler();
        }

        this.playNoteAnimation(noteIndex, clickLoc, success);
    }

    protected function noteAnimationTimerExpired () :void
    {
        var callback :Function = _noteCompletionCallback;

        this.stopNoteAnimation();

        if (callback != null) {
            callback();
        }

        // if the final note was just played, play the outro animation
        if (_finalNotePlayed) {
            this.playRainbowAnimation("rainbow_out", null);
        }
    }

    protected function playNoteAnimation (
        noteIndex :int, clickLoc :Point, success :Boolean,
        completionCallback :Function = null) :void
    {
        this.stopNoteAnimation();

        if (noteIndex >= 0 && noteIndex < _rainbowBands.length) {
            _noteAnimationIndex = noteIndex;

            var band :MovieClip = _rainbowBands[_noteAnimationIndex];

            if (success) {
                // play a happy sound
                var noteSoundChannel :SoundChannel = Sound(new RAINBOW_SOUNDS[noteIndex]).play();
                noteSoundChannel.soundTransform = new SoundTransform(0.5);

                // play an animation on the band
                band.play();

                // create and play a sparkle animation
                var sparkle :MovieClip = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "ui", "sparkle");
                sparkle.mouseEnabled = false;
                sparkle.mouseChildren = false;
                sparkle.x = clickLoc.x;
                sparkle.y = clickLoc.y;

                // the sparkle object will destroy itself when it gets to the "end" frame
                var sparkleObj :SimObject = new SimpleSceneObject(sparkle);
                sparkleObj.addTask(new SerialTask(new WaitForFrameTask("end"), new SelfDestructTask()));
                this.db.addObject(sparkleObj, _curAnim);

            } else {
                // you screwed up

                var failSoundChannel :SoundChannel = Sound(new Resources.SFX_FAIL).play();
                failSoundChannel.soundTransform = new SoundTransform(0.5);

                noteSoundChannel = Sound(new RAINBOW_SOUNDS[noteIndex]).play();
                noteSoundChannel.soundTransform = new SoundTransform(0.5);

                band.filters = [ g_darkenFilter ];
            }

            this.removeNamedTasks(NOTE_ANIMATION_TASK_NAME);
            this.addNamedTask(
                NOTE_ANIMATION_TASK_NAME,
                After(NOTE_ANIMATION_DURATION,
                    new FunctionTask(noteAnimationTimerExpired)));

            _noteCompletionCallback = completionCallback;
        }

        // disable mouse events while the note animation is playing
        if (null != _curAnim) {
            _curAnim.mouseChildren = false;
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


        _noteCompletionCallback = null;
    }

    protected function getScreenLocForRainbowAnimation () :Point
    {
        var p :Point;

        var avatarInfo :AVRGameAvatar = (SimonMain.control.isConnected() ? SimonMain.control.room.getAvatarInfo(_playerId) : null);
        var paintableArea :Rectangle = (SimonMain.control.isConnected() ? SimonMain.control.local.getPaintableArea(false) : null);

        if (null != avatarInfo && null != paintableArea) {
            p = SimonMain.control.local.locationToPaintable(avatarInfo.x, avatarInfo.y, avatarInfo.z);
            p.y -= avatarInfo.bounds.height;

            // clamp rainbow coordinates
            p.x = Math.max(p.x, paintableArea.left + (RAINBOW_ANIMATION_WIDTH * 0.5));
            p.x = Math.min(p.x, paintableArea.right - (RAINBOW_ANIMATION_WIDTH * 0.5));
            p.y = Math.max(p.y, MIN_RAINBOW_Y);

            log.info(
                String(SimonMain.localPlayerId) +
                " avatarInfo: (" + avatarInfo.x + "," + avatarInfo.y + "," + avatarInfo.z + ")" +
                " paintableLoc: (" + p.x + "," + p.y + ")");

        }

        return (null != p ? p : new Point(150, 300));
    }

    protected function get gameMode () :GameMode
    {
        return this.db as GameMode;
    }

    protected function startTimer (evt :SimonEvent) :void
    {
        resetPlayerTimeoutHandler();
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
            var frameNumber :Number = 0;

            if (countdownValue <= 0) {
                frameNumber = 0;
            } else {
                frameNumber = Math.ceil(pieTimer.totalFrames * ((Constants.PLAYER_TIMEOUT_S - countdownValue) / Constants.PLAYER_TIMEOUT_S));
            }
            pieTimer.gotoAndStop(frameNumber);
        }
    }

    protected function resetPlayerTimeoutHandler () :void
    {
        _playerTimeoutCountdown["value"] = Constants.PLAYER_TIMEOUT_S;

        this.stopPlayerTimeoutHandler();

        this.addNamedTask(
            PLAYER_TIMEOUT_TASK_NAME,
            new AnimateValueTask(_playerTimeoutCountdown, 0, Constants.PLAYER_TIMEOUT_S));
    }

    protected function stopPlayerTimeoutHandler () :void
    {
        this.removeNamedTasks(PLAYER_TIMEOUT_TASK_NAME);
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

    protected var _playerId :int;
    protected var _rainbowAnimHandler :AnimationHandler;
    protected var _curAnim :MovieClip;
    protected var _remainingPattern :Array;

    protected var _noteAnimationIndex :int = -1;

    protected var _rainbowBands :Array = [];
    protected var _noteCompletionCallback :Function;

    protected var _playerTimeoutCountdown :Object = { value: 0 };

    protected var log :Log = SimonMain.log;

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
        new Point(-67, -64),
        new Point(-40, -64),
        new Point(-17, -64),
        new Point(2, -64),
        new Point(28, -64),
        new Point(47, -64),
        new Point(70, -64),
    ];

    protected static var g_lightenFilter :ColorMatrixFilter;
    protected static var g_darkenFilter :ColorMatrixFilter;

    protected static const NOTE_ANIMATION_DURATION :Number = 0.75;
    protected static const NOTE_ANIMATION_TASK_NAME :String = "NoteAnimationTask";

    protected static const MIN_RAINBOW_Y :Number = 100;
    protected static const RAINBOW_ANIMATION_WIDTH :Number = 282;

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
