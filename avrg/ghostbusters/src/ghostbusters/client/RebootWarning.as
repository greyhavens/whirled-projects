//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;

import flash.text.TextField;

import com.threerings.util.StringUtil;

import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import ghostbusters.data.Codes;

public class RebootWarning extends Sprite
{
    public function RebootWarning ()
    {
        _bits = new TextBits();
        this.addChild(_bits);

        this.opaqueBackground = 0x994433;
        this.alpha = 1.0;

        _bits.text =
            "Ghosthunters is about to be rebooted for an update! After the reboot, you should be " +
            "able to enter the game and pick up approximately where you left off. Thank you.";
    }

    protected function handleOk () :void
    {
        this.parent.removeChild(this);
    }

    protected var _bits :TextBits;
}
}
