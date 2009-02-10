package bloodbloom.client.view {

import bloodbloom.client.GameCtx;

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.text.TextField;

public class TimerView extends SceneObject
{
    public function TimerView ()
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
        var seconds :int = Math.floor(GameCtx.timeLeft);
        if (seconds != _lastSeconds) {
            var minString :String = String(Math.floor(seconds / 60));
            var secString :String = String(seconds % 60);
            if (secString.length == 0) {
                secString = "0" + secString;
            }

            UIBits.initTextField(_tf, minString + ":" + secString, 1.4, 0, 0x00ff00);

            _lastSeconds = seconds;
        }
    }

    protected var _tf :TextField;
    protected var _lastSeconds :int = -1;
}

}
