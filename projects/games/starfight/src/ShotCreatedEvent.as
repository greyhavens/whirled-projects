package {

import flash.events.Event;

import net.ShipMessage;

public class ShotCreatedEvent extends Event
{
    public var msg :ShipMessage;

    public function ShotCreatedEvent (type :String, msg :ShipMessage)
    {
        super(type, false, false);
        this.msg = msg;
    }
}

}
