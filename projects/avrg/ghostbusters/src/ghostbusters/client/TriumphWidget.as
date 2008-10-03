//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.text.TextField;

import flash.events.MouseEvent;

import com.threerings.util.Command;

import com.threerings.flash.DisplayUtil;

public class TriumphWidget extends ClipHandler
{
    public function TriumphWidget (coins :int, buttonCallback :Function)
    {
        _coins = coins;
        _buttonCallback = buttonCallback;

        super(new Content.GHOST_DEFEATED());
    }

    override protected function handleFrame (... ignored) :void
    {
        super.handleFrame();

        var button :DisplayObject = DisplayUtil.findInHierarchy(this, "continuebutton");
        if (button != null && button != _button) {
            _button = SimpleButton(button);
            _button.addEventListener(MouseEvent.CLICK, buttonClicked);
        }

        var text :DisplayObject = DisplayUtil.findInHierarchy(this, "payout");
        if (text != null && text != _text) {
            _text = TextField(text);
            _text.text = "You've gained " + _coins + " coins for your efforts.";
        }
    }

    protected function buttonClicked (evt :MouseEvent) :void
    {
        _buttonCallback();
    }

    protected var _coins :int;

    protected var _button :SimpleButton;
    protected var _buttonCallback :Function;

    protected var _text :TextField;
}
}
