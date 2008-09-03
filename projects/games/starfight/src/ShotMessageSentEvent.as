package {

import flash.events.Event;

public class ShotMessageSentEvent extends Event
{
    public var ship :Ship;

    public function ShotMessageSentEvent (type :String, ship :Ship)
    {
        super(type, false, false);
        this.ship = ship;
    }
}

}
