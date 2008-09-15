package client {

import com.threerings.util.ArrayUtil;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

public class SoundManager
{
    public function playSound (sound :Sound, startTime :Number = 0, loops :int = 0,
        sndTransform :SoundTransform = null) :SoundChannel
    {
        var channel :SoundChannel = sound.play(startTime, loops, sndTransform);
        if (channel != null) {
            _channels.push(channel);
            channel.addEventListener(Event.SOUND_COMPLETE, function (...ignored) :void {
                soundComplete(channel);
            });
        }

        return channel;
    }

    public function stopSound (channel :SoundChannel) :void
    {
        channel.stop();
        soundComplete(channel);
    }

    public function stopAllSounds () :void
    {
        for each (var channel :SoundChannel in _channels) {
            channel.stop();
        }

        _channels = [];
    }

    protected function soundComplete (channel :SoundChannel) :void
    {
        ArrayUtil.removeFirst(_channels, channel);
    }

    protected var _channels :Array = [];
}

}
