package flashmob.client.view {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFormatAlign;

public class BasicErrorMode extends AppMode
{
    public function BasicErrorMode (err :String)
    {
        _err = err;
    }

    override protected function setup () :void
    {
        var tf :TextField = new TextField();
        UIBits.initTextField(tf, _err, 1.2, WIDTH - 10, 0xFFFFFF, TextFormatAlign.LEFT);

        var g :Graphics = _modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, WIDTH, Math.max(tf.height + 10, MIN_HEIGHT));
        g.endFill();

        tf.x = (_modeSprite.width - tf.width) * 0.5;
        tf.y = (_modeSprite.height - tf.height) * 0.5;
        _modeSprite.addChild(tf);
    }

    protected var _err :String;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
