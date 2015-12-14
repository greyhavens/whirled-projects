package ghostbusters.client.fight.common {

import flash.display.Shape;
import flash.events.MouseEvent;
import flash.text.TextField;

import com.whirled.contrib.simplegame.*;
import flash.events.Event;

public class SplashMode extends AppMode
{
    public function SplashMode (gameName :String)
    {
        _gameName = gameName;
    }

    override protected function setup () :void
    {
        // create a rectangle
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0x000000);
        rect.graphics.drawRect(0, 0, MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT);
        rect.graphics.endFill();

        this.modeSprite.addChild(rect);

        // create the text
        var textField :TextField = new TextField();
        textField.textColor = 0xFFFFFF;
        textField.defaultTextFormat.size = 20;
        textField.text = _gameName + " (click to begin)";
        textField.width = textField.textWidth + 5;
        textField.height = textField.textHeight + 3;
        textField.mouseEnabled = false;

        // center it
        textField.x = (rect.width / 2) - (textField.width / 2);
        textField.y = (rect.height / 2) - (textField.height / 2);

        this.modeSprite.addChild(textField);
    }

    override protected function enter () :void
    {
        // dismiss the mode on mouseclick
        this.modeSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    override protected function exit () :void
    {
        this.modeSprite.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    protected function onMouseDown (e :Event) :void
    {
        MainLoop.instance.popMode();
    }

    protected var _gameName :String;
}

}
