package flashmob.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import flashmob.util.SpriteUtil;

public class TimerView extends SceneObject
{
    public function TimerView (time :Number = 0)
    {
        _time = time;

        _sprite = SpriteUtil.createSprite();
        _tf = new TextField();
        _sprite.addChild(_tf);
    }

    public function set time (val :Number) :void
    {
        _time = val;
    }

    public function get time () :Number
    {
        return _time;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        _time = Math.max(_time - dt, 0);
        updateView();
    }

    protected function updateView () :void
    {
        if (Math.abs(_lastUpdate - _time) < 1) {
            return;
        }

        var time :int = Math.floor(_time);
        var mins :int = time / 60;
        var secs :int = time % 60;
        var minStr :String = String(mins);
        var secStr :String = String(secs);
        if (minStr.length < 2) {
            minStr = "0" + minStr;
        }
        if (secStr.length < 2) {
            secStr = "0" + secStr;
        }

        UIBits.initTextField(_tf, minStr + ":" + secStr, 2.5, 0, 0x0000ff);
        _tf.x = -_tf.width * 0.5;
        _tf.y = -_tf.height * 0.5;
    }

    protected var _sprite :Sprite;
    protected var _tf :TextField;
    protected var _time :Number;

    protected var _lastUpdate :Number = Number.MIN_VALUE;
}

}
