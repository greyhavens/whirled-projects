//
// $Id$

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.SampleDataEvent;

import flash.media.Microphone;
import flash.media.Sound;

import flash.utils.ByteArray;

import com.threerings.util.NamedValueEvent;

import com.whirled.ToyControl;

import com.whirled.contrib.Chunker;

/**
 * Provides voice chat for whirled rooms.
 */
[SWF(width="600", height="100")]
public class VoiceChat extends Sprite
{
    public function VoiceChat ()
    {
        _ctrl = new ToyControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);

        // TEMP: so we can see it
        graphics.beginFill(0xFFDD33);
        graphics.drawRect(0, 0, 600, 100);
        graphics.endFill();

        _chunker = new Chunker(_ctrl, "");
        _chunker.addEventListener(Event.COMPLETE, handleChunk);

        _ctrl.doLog("====== VoiceChat starting up v2");

        try {
            setupMic();
        } catch (e :Error) {
            _ctrl.doLog("Got an error: " + e.name + ", " + e.message + "; " + e.getStackTrace());
        }
    }

    protected function setupMic () :void
    {
        _mic = _ctrl.getMicrophone();
        _ctrl.doLog("Got microphone: " + _mic);
        _mic.setSilenceLevel(0, 2000); // TODO
        _mic.gain = 100;
        _mic.rate = 44;
        _mic.addEventListener(SampleDataEvent.SAMPLE_DATA, handleMicData);
        _ctrl.doLog("Theoretically now listening to the microphone");
    }

    protected function handleMicData (event :SampleDataEvent) :void
    {
        var ba :ByteArray = event.data;
        _ctrl.doLog("Got mic data! (" + ba.position + " / " + ba.length + ")");
    }

    protected function handleChunk (event :NamedValueEvent) :void
    {
        var ba :ByteArray = event.value;
        _ctrl.doLog("Got sound from " + event.name + ", starting at position " + ba.position);

        // play this sound until it finishes...
        var sound :Sound = new Sound();
        sound.addEventListener(SampleDataEvent.SAMPLE_DATA,
            function (outEvent :SampleDataEvent) :void
            {
                var outData :ByteArray = outEvent.data;
                var sample :Number;
                for (var ii :int = Math.min(8192, ba.bytesAvailable); ii >= 0; ii--) {
                    sample = ba.readFloat();
                    outData.writeFloat(sample);
                    outData.writeFloat(sample);
                }
            });
        sound.play();
    }

    protected function handleUnload (event :Event) :void
    {
        // TODO?
    }

    protected var _ctrl :ToyControl;

    protected var _chunker :Chunker;

    /** Our microphone. */
    protected var _mic :Microphone;
}
}
