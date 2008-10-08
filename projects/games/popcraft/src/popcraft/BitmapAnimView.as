package popcraft {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class BitmapAnimView extends SceneObject
{
    public function BitmapAnimView (anim :BitmapAnim)
    {
        _sprite = new Sprite();
        _bitmap = new Bitmap();
        _sprite.addChild(_bitmap);

        this.anim = anim;
    }

    public function set anim (newAnim :BitmapAnim) :void
    {
        _anim = newAnim;
        if (_anim != null) {
            _elapsedTime = 0;
            this.setFrame(0);
        }
    }

    public function get anim () :BitmapAnim
    {
        return _anim;
    }

    public function get frameIndex () :int
    {
        return _curFrameIndex;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (_anim != null) {
            _elapsedTime += dt;

            var elapsedFrames :int = Math.floor(_elapsedTime * _anim.frameRate);
            this.setFrame(elapsedFrames % _anim.frames.length);
        }
    }

    protected function setFrame (index :int) :void
    {
        var frame :BitmapAnimFrame = _anim.frames[index];

        _bitmap.bitmapData = frame.bitmapData;
        _bitmap.x = frame.offset.x;
        _bitmap.y = frame.offset.y;

        _curFrameIndex = index;
    }

    protected var _anim :BitmapAnim;
    protected var _elapsedTime :Number = 0;
    protected var _sprite :Sprite;
    protected var _bitmap :Bitmap;

    protected var _curFrameIndex :int;
}

}
