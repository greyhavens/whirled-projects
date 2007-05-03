package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Rectangle;

[SWF(width="2000", height="1000")]
public class Twists extends Sprite
{
    public function Twists ()
    {
        var bd :BitmapData = new BitmapData(2000, 2000, true, 0x00FFFFFF);

        var rect :Rectangle = new Rectangle(0, 0, 1, 2000);
        for (var xx :int = 0; xx < 2000; xx += 4) {
            rect.x = xx;
            bd.fillRect(rect, 0xFF000000);
        }

        var bmp1 :Bitmap = new Bitmap(bd);
        var bmp2 :Bitmap = new Bitmap(bd);

        _spr1.blendMode = BlendMode.INVERT;
        _spr1.x = 1000;
        _spr1.y = 500;
        _spr2.blendMode = BlendMode.INVERT;
        _spr2.x = 1000;
        _spr2.y = 500;
        bmp1.x = -1000;
        bmp1.y = -1000;
        bmp2.x = -1000;
        bmp2.y = -1000;
        _spr1.addChild(bmp1);
        _spr2.addChild(bmp2);

        addChild(_spr1);
        addChild(_spr2);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);
    }

    protected function handleAdded (... ignored) :void
    {
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleRemoved (... ignored) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleFrame (... ignored) :void
    {
        _spr1.rotation += .4;
        _spr2.rotation -= .3;
    }

    protected var _spr1 :Sprite = new Sprite();
    protected var _spr2 :Sprite = new Sprite();
}
}
