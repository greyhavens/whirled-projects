package {

import flash.media.SoundMixer;

import flash.utils.ByteArray;

import com.threerings.flash.FrameSprite;

[SWF(width="512", height="512")]
public class SoundSpectrum extends FrameSprite
{
    override protected function handleFrame (... ignored) :void
    {
        SoundMixer.computeSpectrum(_ba, true, 0);

        graphics.clear();
        for (var ii :int = 0; ii < 256; ii += 8) {
            var num :Number = 360 * _ba.readFloat();
            graphics.lineStyle(num/15, 0x0066FF|(num << 8));
            graphics.drawCircle(256, 256, ii);
        }
    }

    protected var _ba :ByteArray = new ByteArray();
}
}
