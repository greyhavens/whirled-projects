package popcraft.ui {

import com.whirled.contrib.simplegame.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.text.TextField;

import popcraft.*;

public class GenericLoadingMode extends AppMode
{
    public function GenericLoadingMode ()
    {
        var zombieBg :Bitmap = ClientCtx.instantiateBitmap("zombieBg");
        _modeSprite.addChild(zombieBg);

        var frame :DisplayObject = UIBits.createFrame(FRAME_WIDTH, FRAME_HEIGHT);
        frame.x = (Constants.SCREEN_SIZE.x - FRAME_WIDTH) * 0.5;
        frame.y = (Constants.SCREEN_SIZE.y - FRAME_HEIGHT) * 0.5;
        _modeSprite.addChild(frame);

        this.loadingText = "Loading";
    }

    protected function set loadingText (text :String) :void
    {
        if (_tf != null) {
            _tf.parent.removeChild(_tf);
            _tf = null;
        }

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

        if (_tf == null) {
            _tf = UIBits.createTitleText(text);
            _tf.x = (Constants.SCREEN_SIZE.x - _tf.width) * 0.5;
            _tf.y = (Constants.SCREEN_SIZE.y - _tf.height) * 0.5;
            _modeSprite.addChild(_tf);
        } else {
            _tf.text = text;
        }
    }

    protected var _numDots :int;
    protected var _dotCountdown :Number;
    protected var _tf :TextField;
    protected var _loadingText :String;

    protected static const MAX_DOTS :int = 3;
    protected static const DOT_TIME :Number = 0.5;

    protected static const FRAME_WIDTH :int = 370;
    protected static const FRAME_HEIGHT :int = 60;
}

}
