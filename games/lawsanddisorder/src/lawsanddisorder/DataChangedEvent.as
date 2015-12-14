package lawsanddisorder {

import flash.events.Event;

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