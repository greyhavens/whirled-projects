package {

import flash.events.Event;

public class ShotCreatedEvent extends Event
{
    public var args :Array;

    public function ShotCreatedEvent (type :String, args :Array)
    {
        super(type, false, false);
        this.args = args;
    }
}

}
