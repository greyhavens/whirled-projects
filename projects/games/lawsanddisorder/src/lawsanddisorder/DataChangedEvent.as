package lawsanddisorder {

import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.MessageReceivedEvent;
import com.threerings.util.HashMap;
import com.whirled.game.GameSubControl;

import lawsanddisorder.component.*;

/**
 * Event class for dealing with changes to distributed data.
 */
public class DataChangedEvent extends Event
{
    public function DataChangedEvent (name :String, oldValue :*, newValue :*, index :int)
    {
        super(name);
        this.name = name;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.index = index;
    }

    public var name :String;
    public var oldValue :*;
    public var newValue :*;
    public var index :int;

}
}