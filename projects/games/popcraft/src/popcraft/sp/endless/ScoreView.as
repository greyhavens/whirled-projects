package popcraft.sp.endless {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;

import popcraft.*;
import popcraft.ui.UIBits;

public class ScoreView extends SceneObject
{
    public function ScoreView ()
    {
        _tf = UIBits.createText("00000 (1x)", 1.5, 0, 0xFFFFFF);
        _tf.x = 3;
        _tf.y = 3;

        _sprite = new Sprite();
        _sprite.addChild(_tf);

        var g :Graphics = _sprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, _tf.width + 6, _tf.height + 6);
        g.endFill();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var newScore :int = EndlessGameContext.score;
        var mult :int = EndlessGameContext.scoreMultiplier;
        if (_lastScore != newScore || _lastMultiplier != mult) {

            var text :String = String(newScore);
            var numLeadingDigits :int = NUM_DIGITS - text.length;
            for (var ii :int = 0; ii < numLeadingDigits; ++ii) {
                text = "0" + text;
            }

            text += " (" + mult + "x)";

            _sprite.removeChild(_tf);
            _tf = UIBits.createText(text, 1.5, 0, 0xFFFFFF);
            _tf.x = 3;
            _tf.y = 3;
            _sprite.addChild(_tf);

            _lastScore = newScore;
            _lastMultiplier = mult;
        }
    }

    protected var _sprite :Sprite;
    protected var _tf :TextField;
    protected var _lastScore :int;
    protected var _lastMultiplier :int;

    protected static const NUM_DIGITS :int = 5;
}

}
