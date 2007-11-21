package {

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.events.Event;

public class SoundLoop
{
    public function SoundLoop (sound :Sound)
    {
        _sound = sound;
    }

    public function loop () :void
    {
        // no-op if we're already playing
        if (_soundChannel != null) {
            return;
        }
        _soundChannel = _sound.play(0);
        if (_soundChannel != null) {
            _soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
        }
    }

    public function stop () :void
    {
        if (_soundChannel != null) {
            _soundChannel.stop();
            _soundChannel = null;
        }
    }

    protected function soundCompleteHandler (event :Event) :void
    {
        _soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
        _soundChannel = _sound.play(0);
        _soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
    }

    protected var _sound :Sound;
    protected var _soundChannel :SoundChannel;
}
}
