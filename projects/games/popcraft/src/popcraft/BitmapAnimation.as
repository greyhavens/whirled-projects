package popcraft {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class BitmapAnimation extends SceneObject
{
    public function BitmapAnimation (frames :Array, frameRate :Number)
    {
        _frames = frames;
        _frameRate = frameRate;

        _sprite = new Sprite();
        _bitmap = new Bitmap();
        _sprite.addChild(_bitmap);

        this.setFrame(0);
    }

    public function set bitmapDatas (val :Array) :void
    {
        _frames = val;
        this.setFrame(0);
    }

    public function set frameRate (val :Number) :void
    {
        _frameRate = val;
        this.setFrame(0);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        _elapsedTime += dt;

        var elapsedFrames :int = Math.floor(_elapsedTime * _frameRate);
        this.setFrame(elapsedFrames % _frames.length);
    }

    protected function setFrame (index :int) :void
    {
        var frame :BitmapAnimationFrame = _frames[index];

        _bitmap.bitmapData = frame.bitmapData;
        _bitmap.x = frame.offset.x;
        _bitmap.y = frame.offset.y;
    }

    protected var _frames :Array;
    protected var _frameRate :Number;
    protected var _elapsedTime :Number = 0;
    protected var _sprite :Sprite;
    protected var _bitmap :Bitmap;
}

}
