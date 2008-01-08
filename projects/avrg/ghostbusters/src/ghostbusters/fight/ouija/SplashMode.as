package ghostbusters.fight.ouija
{

import flash.display.Shape;
import flash.events.MouseEvent;
import flash.text.TextField;

import com.whirled.contrib.core.*;

public class SplashMode extends AppMode
{
    public function SplashMode (gameName :String)
    {
        _gameName = gameName;
    }
    
    override public function setup () :void
    {
        // create a rectangle
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0x000000);
        rect.graphics.drawRect(0, 0, 280, 222);
        rect.graphics.endFill();
        
        this.addChild(rect);
        
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
        
        this.addChild(textField);
        
        // dismiss the mode on mouseclick
        this.addEventListener(
            MouseEvent.MOUSE_DOWN,
            function (e :MouseEvent) :void { MainLoop.instance.popMode(); }
        );
    }
    
    protected var _gameName :String;
}

}