package bloodbloom.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.text.TextField;

import bloodbloom.client.*;

public class StatView extends SceneObject
{
    public function StatView ()
    {
        _tf = UIBits.createText("");
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        UIBits.initTextField(_tf, "FPS: " + ClientCtx.mainLoop.fps.toFixed(1), 1.3, 0, 0x0000ff);
    }

    protected var _tf :TextField;
}

}
