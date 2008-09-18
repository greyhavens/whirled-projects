package starfight.client {

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

public class SoundLoop
{
    public function SoundLoop (sound :Sound)
    {
        _sound = sound;
    }

    public function play (val :Boolean) :void
    {
        if (val) {
            loop();
        } else {
            stop();
        }
    }

    public function loop () :void
    {
        // no-op if we're already playing
        if (_soundChannel != null) {
            return;
        }
        _soundChannel = ClientContext.sounds.playSound(_sound);
        if (_soundChannel != null) {
            _soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
        }
    }

    public function stop () :void
    {
        if (_soundChannel != null) {
            ClientContext.sounds.stopSound(_soundChannel);
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
            _soundChannel = null;
        }
    }

    protected function soundCompleteHandler (event :Event) :void
    {
        _soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
        _soundChannel = ClientContext.sounds.playSound(_sound);
        _soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
    }

    protected var _sound :Sound;
    protected var _soundChannel :SoundChannel;
}
}
