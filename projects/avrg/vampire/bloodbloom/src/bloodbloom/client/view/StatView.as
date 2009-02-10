package bloodbloom.client.view {

import bloodbloom.client.*;

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.text.TextField;

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
        var fpsString :String = "FPS=" + ClientCtx.mainLoop.fps.toFixed(1);
        var beatTimeString :String = "Beat time=" + GameCtx.heart.totalBeatTime;
        UIBits.initTextField(_tf, fpsString + "\n" + beatTimeString, 1.3, 0, 0x0000ff);
    }

    protected var _tf :TextField;
}

}
