//
// $Id$

package {

import flash.display.*;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import com.threerings.util.Command;

import com.whirled.*;

[SWF(width="128", height="128")]
public class Popper extends Sprite
{
    public function Popper ()
    {
        _ctrl = new FurniControl(this);

        var ba :ByteArray = _ctrl.getDefaultDataPack();
        if (ba != null) {
            _pack = new DataPack(ba);
            _pack.getDisplayObjects({panel: "Panel", button: "Button"}, init);
        } else {
            trace("No datapack, 10 seconds to self destruct");
        }
    }

    protected function init (images :Object) :void
    {
        _panel = images.panel as DisplayObject;
        _button = images.button as DisplayObject;

        // Sigh. Apparently we can't add the mouse listeners on 'this'
        // So we have to make a container
        var s: Sprite = new Sprite();
        s.addChild(_button);
        addChild(s);

        // function function function function
        function press (amount :Number) :void {
            _button.x = amount;
            _button.y = amount;
        }

        Command.bind(s, MouseEvent.CLICK, pop);

        if ( ! (_button is InteractiveObject)) {
            Command.bind(s, MouseEvent.MOUSE_OVER, press, 2);
            Command.bind(s, MouseEvent.MOUSE_OUT, press, 0);
            Command.bind(s, MouseEvent.MOUSE_DOWN, press, 10);
            Command.bind(s, MouseEvent.MOUSE_UP, press, 2);
        }
    }

    protected function pop () :void
    {
        _ctrl.showPopup(_pack.getString("Title"), _panel, _panel.width, _panel.height, 0, 0.9);
    }

    protected var _button :DisplayObject;
    protected var _panel :DisplayObject;

    protected var _pack :DataPack;
    protected var _ctrl :FurniControl;

}
}
