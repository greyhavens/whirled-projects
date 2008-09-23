package popcraft.ui {

import com.whirled.contrib.simplegame.*;

import flash.display.Graphics;
import flash.text.TextField;

import popcraft.*;

public class GenericLoadingMode extends AppMode
{
    public function GenericLoadingMode ()
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 1);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        _text = new TextField();
        this.modeSprite.addChild(_text);

        loadingText = "Loading...";
    }

    protected function set loadingText (text :String) :void
    {
        UIBits.initTextField(_text, text, 2, Constants.SCREEN_SIZE.x - 30, 0xFFFFFF);
        _text.x = (Constants.SCREEN_SIZE.x - _text.width) * 0.5;
        _text.y = (Constants.SCREEN_SIZE.y - _text.height) * 0.5;
    }

    protected var _text :TextField;
}

}
