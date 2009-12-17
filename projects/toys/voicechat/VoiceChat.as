//
// $Id$

package {

import flash.display.Sprite;

import flash.events.ActivityEvent;
import flash.events.StatusEvent;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.SampleDataEvent;
import flash.events.TimerEvent;

import flash.media.Microphone;
import flash.media.Sound;
import flash.media.SoundCodec;

import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;

import com.threerings.util.NamedValueEvent;

import com.whirled.ToyControl;

import com.whirled.contrib.Chunker;

/**
 * Provides voice chat for whirled rooms.
 */
[SWF(width="215", height="138")]
public class VoiceChat extends Sprite
{
    /** The maximum sample time, in milliseconds. */
    public static const MAX_SAMPLE :int = 5000;

    public function VoiceChat ()
    {
        _ctrl = new ToyControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);

        _chunker = new Chunker(_ctrl, "");
        _chunker.addEventListener(Event.COMPLETE, handleChunk);

        log("====== VoiceChat starting up v11");
        _recTimer = new Timer(MAX_SAMPLE, 1);
        _recTimer.addEventListener(TimerEvent.TIMER, handleTimer);

        _button = new Sprite();
        addChild(_button);

        setState(STATE_UNREADY);
        try {
            setupMic();
            readyToRecord();
        } catch (e :Error) {
            log("Got an error: " + e.name + ", " + e.message + "; " + e.getStackTrace());
        }
    }

    protected static const STATE_COLORS :Array = [ 0x003399, 0xDDFF11, 0xFF0000, 0x666666 ];
    protected function setState (state :int) :void
    {
        _button.graphics.clear();
        _button.graphics.beginFill(STATE_COLORS[state]);
        _button.graphics.drawRect(0, 0, 215, 138);
        _button.graphics.endFill();
        log("State now : " + state);
    }

    protected function setupMic () :void
    {
        _mic = _ctrl.getMicrophone();
        log("Got microphone: " + _mic);
        _mic.codec = SoundCodec.SPEEX;
        _mic.setSilenceLevel(0, 2000); // TODO
        _mic.gain = 100;
        _mic.rate = 44;
        _mic.addEventListener(ActivityEvent.ACTIVITY, handleMicActivity);
        _mic.addEventListener(StatusEvent.STATUS, handleMicStatus);
        _mic.addEventListener(SampleDataEvent.SAMPLE_DATA, handleMicData);
        log("Microphone names: " + Microphone.names.join());
        debugMic();
    }

    protected function readyToRecord () :void
    {
        _button.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
        setState(STATE_READY);
    }

    protected function startRecording () :void
    {
        _output = new ByteArray();
        _button.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
        _button.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
        //_mic.addEventListener(SampleDataEvent.SAMPLE_DATA, handleMicData);
        _recTimer.start();
        setState(STATE_RECORDING);
    }

    protected function stopRecording () :void
    {
        _recTimer.reset();
        _button.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
        //_mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, handleMicData);

        var out :ByteArray = _output;
        _output = null;
        if (out.length > 0) {
            _chunker.send(out);
            setState(STATE_WAITING);
        } else {
            log("nothing to send...");
            readyToRecord();
        }
    }

    protected function handleMouseDown (event :MouseEvent) :void
    {
        startRecording();
    }

    protected function handleTimer (event :TimerEvent) :void
    {
        stopRecording();
    }

    protected function handleMouseUp (event :MouseEvent) :void
    {
        stopRecording();
    }

    protected function handleMicActivity (event :ActivityEvent) :void
    {
        log("activating " + event.activating + ", activityLevel=" + _mic.activityLevel);
        if (event.activating) {
            _mic.gain = 100;
            _mic.rate = 44;
            debugMic();
        }
    }

    protected function handleMicStatus (event :StatusEvent) :void
    {
        log("status level=" + event.level + ", code=" + event.code);
    }

    protected function handleMicData (event :SampleDataEvent) :void
    {
        if (_output == null) {
            return;
        }
        log("Got mic data!  " + event.data.length);
        _output.writeBytes(event.data);
        log(" output byte position is now: " + _output.position);
    }

    protected function handleChunk (event :NamedValueEvent) :void
    {
        log("Got sound from " + event.name + ", length: " + event.value.length);

        // play this sound until it finishes...
        var sound :Sound = new Sound();
        sound.addEventListener(SampleDataEvent.SAMPLE_DATA, handlePlaySound);
        sound.addEventListener(Event.COMPLETE, handleSoundComplete);
        _sounds[sound] = event.value;
        sound.play();

        if (event.name == String(_ctrl.getInstanceId())) {
            readyToRecord();
        }
    }

    protected function handlePlaySound (event :SampleDataEvent) :void
    {
        var ba :ByteArray = ByteArray(_sounds[event.target]);
        var count :int = Math.min(CHUNK, int(ba.bytesAvailable / 4));
        var s :Number;
        for (var ii :int = 0; ii < count; ii++) {
            s = ba.readFloat();
            event.data.writeFloat(s);
            event.data.writeFloat(s);
        }
        log("Wrote " + count + " floats, " + ba.bytesAvailable + " bytes left");

        if (count < CHUNK) {
            delete _sounds[event.target];
        }
    }

    protected function handleSoundComplete (event :Event) :void
    {
        log("Sound complete: " + event.target);
        delete _sounds[event.target];
    }

    protected function handleUnload (event :Event) :void
    {
        _recTimer.stop();
    }

    protected function debugMic () :void
    {
        log("Microphone: " + _mic.name +
            ", codec=" + _mic.codec +
            ", muted=" + _mic.muted +
            ", index=" + _mic.index +
            ", rate=" + _mic.rate +
            ", gain=" + _mic.gain +
            ", echo=" + _mic.useEchoSuppression +
            ", silenceLevel=" + _mic.silenceLevel +
            ", framesPerPacket=" + _mic.framesPerPacket);
    }

    protected function log (msg :String) :void
    {
        _ctrl.doLog(msg);
    }

    protected var _sounds :Dictionary = new Dictionary();

    protected var _ctrl :ToyControl;

    protected var _chunker :Chunker;

    /** Our microphone. */
    protected var _mic :Microphone;

    protected var _recTimer :Timer;

    protected var _output :ByteArray;

    protected var _button :Sprite;

    protected static const CHUNK :int = 8192;

    protected static const STATE_UNREADY :int = 0;
    protected static const STATE_READY :int = 1;
    protected static const STATE_RECORDING :int = 2;
    protected static const STATE_WAITING :int = 3;
}
}
