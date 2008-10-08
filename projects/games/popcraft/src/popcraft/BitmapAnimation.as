package popcraft {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;

public class BitmapAnimation extends SceneObject
{
    public function BitmapAnimation (bitmapDatas :Array, frameRate :Number)
    {
        _bitmapDatas = bitmapDatas;
        _frameRate = frameRate;

        _bitmap = new Bitmap();
        this.setFrame(0);
    }

    public function set bitmapDatas (val :Array) :void
    {
        _bitmapDatas = bitmapDatas;
        this.setFrame(0);
    }

    public function set frameRate (val :Number) :void
    {
        _frameRate = val;
        this.setFrame(0);
    }

    override public function get displayObject () :DisplayObject
    {
        return _bitmap;
    }

    override protected function update (dt :Number) :void
    {
        _elapsedTime += dt;

        var elapsedFrames :int = Math.floor(_elapsedTime * _frameRate);
        this.setFrame(elapsedFrames % _bitmapDatas.length);
    }

    protected function setFrame (index :int) :void
    {
        _bitmap.bitmapData = _bitmapDatas[index];
    }

    protected var _bitmapDatas :Array;
    protected var _frameRate :Number;
    protected var _elapsedTime :Number = 0;
    protected var _bitmap :Bitmap;
}

}
