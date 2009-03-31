package vampire.feeding.client {

import vampire.feeding.client.*;

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.text.TextField;

public class StatView extends SceneObject
{
    public function StatView ()
    {
        _tf = TextBits.createText("");
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        var fpsString :String = "FPS=" + ClientCtx.mainLoop.fps.toFixed(1);
        TextBits.initTextField(_tf, fpsString, 1.5, 0, 0x0000ff);
    }

    protected var _tf :TextField;
}

}
