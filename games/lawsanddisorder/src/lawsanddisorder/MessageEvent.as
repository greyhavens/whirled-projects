package lawsanddisorder {

import flash.events.Event;

/**
 * Event class for dealing with messages from other player clients
 */
public class MessageEvent extends Event
{
    public function MessageEvent (name :String, value:*)
    {
        super(name);
        this.name = name;
        this.value = value;
    }

    public var name :String;
    public var value :*;
}
}