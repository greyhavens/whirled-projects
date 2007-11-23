package {

import flash.events.Event;

import com.threerings.util.NameValueEvent;

public class EntityStateEvent extends NameValueEvent
{
    public static const STATE_CHANGED :String = "entityStateChanged";

    public function EntityStateEvent (type :String, name :String, value :Object)
    {
        super(type, name, value);
    }

    override public function clone () :Event
    {
        return new EntityStateEvent(type, name, value);
    }
}
}
