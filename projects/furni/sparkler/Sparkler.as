package {

import com.threerings.flash.FrameSprite;

[SWF(width="200", height="200")]
public class Sparkler extends FrameSprite
{
    public function Sparkler ()
    {
        super(false);
    }

//    override public function hitTestPoint (
//        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
//    {
//        return false;
//    }

    override protected function handleFrame (... ignored) :void
    {
        var mx :Number = mouseX;
        var my :Number = mouseY;
        if (mx != _lastX || my != _lastY) {
            _lastX = mx;
            _lastY = my;
            addChild(new Sparkle(mx, my));
        }
    }

    protected var _lastX :Number = NaN;
    protected var _lastY :Number = NaN;
}
}
