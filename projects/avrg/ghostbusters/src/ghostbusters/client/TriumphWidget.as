//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObject;
import flash.display.SimpleButton;

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

        // TODO: tweak award text
    }

    protected function buttonClicked (evt :MouseEvent) :void
    {
        _buttonCallback();
    }

    protected var _button :SimpleButton;

    protected var _coins :int;

    protected var _buttonCallback :Function;
}
}
