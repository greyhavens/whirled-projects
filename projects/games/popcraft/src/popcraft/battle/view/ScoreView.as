package popcraft.battle.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.sp.endless.EndlessGameMode;
import popcraft.ui.UIBits;

public class ScoreView extends SceneObject
{
    public function ScoreView (mode :EndlessGameMode)
    {
        _mode = mode;

        _tf = UIBits.createText("00000", 1.5, 0, 0xFFFFFF);
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

    override protected function update (dt:Number) :void
    {
        super.update(dt);

        var newScore :int = _mode.score;
        if (_lastScore != newScore) {

            var text :String = String(newScore);
            var numLeadingDigits :int = NUM_DIGITS - text.length;
            for (var ii :int = 0; ii < numLeadingDigits; ++ii) {
                text = "0" + text;
            }

            _sprite.removeChild(_tf);
            _tf = UIBits.createText(text, 1.5, 0, 0xFFFFFF);
            _tf.x = 3;
            _tf.y = 3;
            _sprite.addChild(_tf);

            _lastScore = newScore;
        }
    }

    protected var _sprite :Sprite;
    protected var _tf :TextField;
    protected var _mode :EndlessGameMode;
    protected var _lastScore :int;

    protected static const NUM_DIGITS :int = 5;
}

}
