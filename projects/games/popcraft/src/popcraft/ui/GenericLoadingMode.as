package popcraft.ui {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.text.TextField;

import popcraft.*;

public class GenericLoadingMode extends AppMode
{
    public function GenericLoadingMode ()
    {
        // If we've loaded the zombieBg, use it as a background. Otherwise, use black.
        var zombieBg :Bitmap = ImageResource.instantiateBitmap("zombieBg");
        if (zombieBg != null) {
            _modeSprite.addChild(zombieBg);
            _tf = UIBits.createText("");

        } else {
            var g :Graphics = _modeSprite.graphics;
            g.beginFill(0, 1);
            g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
            g.endFill();

            _tf = new TextField();
        }

        _modeSprite.addChild(_tf);

        this.loadingText = "Loading";
    }

    protected function set loadingText (text :String) :void
    {
        _loadingText = text;
        _numDots = MAX_DOTS;
        _dotCountdown = DOT_TIME;
        updateText();
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        _dotCountdown -= dt;
        if (_dotCountdown <= 0) {
            if (++_numDots > MAX_DOTS) {
                _numDots = 0;
            }
            updateText();
            _dotCountdown = DOT_TIME;
        }
    }

    protected function updateText () :void
    {
        var text :String = _loadingText;
        for (var ii :int = 0; ii < _numDots; ii++) {
            text += ".";
        }

        UIBits.initTextField(_tf, text, 3, Constants.SCREEN_SIZE.x - 30, 0xFFFFFF);
        _tf.x = (Constants.SCREEN_SIZE.x - _tf.width) * 0.5;
        _tf.y = (Constants.SCREEN_SIZE.y - _tf.height) * 0.5;
    }

    protected var _numDots :int;
    protected var _dotCountdown :Number;
    protected var _tf :TextField;
    protected var _loadingText :String;

    protected static const MAX_DOTS :int = 3;
    protected static const DOT_TIME :Number = 0.5;
}

}
