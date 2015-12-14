package {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.media.SoundMixer;

import flash.utils.ByteArray;

import com.threerings.flash.FrameSprite;

[SWF(width="512", height="512")]
public class SoundSpectrum2 extends FrameSprite
{
    public function SoundSpectrum2 ()
    {
        // create a mask to reserve our shape..
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0xFFFFFF);
        masker.graphics.drawRect(0, 0, 512, 512);
        masker.graphics.endFill();
        this.mask = masker;
        addChild(masker);

        blendMode = BlendMode.INVERT;
//        alpha = .5;
    }

    override protected function handleFrame (... ignored) :void
    {
        SoundMixer.computeSpectrum(_ba, false, 0);

        var ii :int;
        graphics.clear();
        graphics.lineStyle(1, 0xFF0000);
        // draw the left channel inverted so that things may "match" in the middle
        for (ii = 255; ii >= 0; ii--) {
            graphics.moveTo(ii, 256);
            graphics.lineTo(ii, 256 + (256 * _ba.readFloat()));
        }
        for (ii = 256; ii < 512; ii++) {
            graphics.moveTo(ii, 256);
            graphics.lineTo(ii, 256 + (256 * _ba.readFloat()));
        }
    }

    protected var _ba :ByteArray = new ByteArray();

    protected var _spec :Sprite;
}
}
