package popcraft.ui {

import com.whirled.contrib.simplegame.*;

import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import popcraft.*;

public class GenericLoadErrorMode extends AppMode
{
    public function GenericLoadErrorMode (err :String)
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 1);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var text :TextField = new TextField();
        UIBits.initTextField(text, err, 1, Constants.SCREEN_SIZE.x - 30, 0xFFFFFF,
            TextFormatAlign.LEFT);
        text.x = (Constants.SCREEN_SIZE.x - text.width) * 0.5;
        text.y = (Constants.SCREEN_SIZE.y - text.height) * 0.5;
        this.modeSprite.addChild(text);
    }
}

}
