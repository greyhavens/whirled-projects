//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObject;
import flash.display.SimpleButton;

import flash.events.MouseEvent;

import com.threerings.util.Command;

import com.threerings.flash.DisplayUtil;

public class ReviveWidget extends ClipHandler
{
    public function ReviveWidget ()
    {
        super(new Content.PLAYER_DIED());
    }

    override protected function handleFrame (... ignored) :void
    {
        super.handleFrame();

        var button :DisplayObject = DisplayUtil.findInHierarchy(this, "revivebutton");
        if (button != null && button != _button) {
            _button = SimpleButton(button);
            Command.bind(_button, MouseEvent.CLICK, GameController.REVIVE);
        }
    }

    protected var _button :SimpleButton;
}
}
