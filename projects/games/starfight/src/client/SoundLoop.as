package client {

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
        _soundChannel = _sound.play(0, int.MAX_VALUE);
    }

    public function stop () :void
    {
        if (_soundChannel != null) {
            _soundChannel.stop();
            _soundChannel = null;
        }
    }

    protected var _sound :Sound;
    protected var _soundChannel :SoundChannel;
}
}
