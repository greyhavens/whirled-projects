package {

import flash.text.TextField;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

[Event("ButtonClick")]

public class Button extends Sprite
{
    public function Button (text :String = "", action :String = "")
    {
        _text = new TextField();
        _action = action;

        addChild(_text);
        addEventListener(MouseEvent.CLICK, handleMouseClick);

        _text.text = text;
        _text.selectable = false;
        _text.autoSize = TextFieldAutoSize.LEFT;
    }

    public function set text (value:String) :void
    {
        _text.text = value;
    }

    public function get text () :String
    {
        return _text.text;
    }

    public function get action () :String
    {
        return _action;
    }

    protected function handleMouseClick (event :MouseEvent) :void
    {
        if (event.target == this || event.target == _text) {
            dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, action));
        }
    }

    protected var _text :TextField;
    protected var _action :String;
}

}
