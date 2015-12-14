package {

import flash.display.DisplayObject;

import flash.geom.Matrix;

import com.threerings.flash.FrameSprite;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="600", height="450")]
public class NonScaling extends FrameSprite
{
    public static const NOSCALE_STATE :String = "No scaling";

    public static const WIDTH :int = 600;
    public static const HEIGHT :int = 450;

    public function NonScaling ()
    {
        _ctrl = new AvatarControl(this);
        _ctrl.registerStates("Default", NOSCALE_STATE);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, checkState);

        _image = new IMAGE() as DisplayObject;
        addChild(_image);

        checkState();
    }

    protected function checkState (... ignored) :void
    {
        _state = _ctrl.getState();
        handleFrame();
    }

    override protected function handleFrame (... ignored) :void
    {
        if (_state == NOSCALE_STATE) {
            var matrix :Matrix = this.transform.concatenatedMatrix;
            _image.scaleX = 1 / matrix.a;
            _image.scaleY = 1 / matrix.d;

        } else {
            _image.scaleX = 1;
            _image.scaleY = 1;
        }

        _image.x = (WIDTH - _image.width) / 2;
        _image.y = HEIGHT - _image.height;
        _ctrl.setHotSpot(WIDTH/2, HEIGHT, _image.height);
    }

    protected var _ctrl :AvatarControl;

    protected var _state :String;

    protected var _image :DisplayObject;

    [Embed(source="mug.png")]
    protected static const IMAGE :Class;
}
}
