package starfight {

import flash.events.Event;

import starfight.net.ShipShotMessage;

public class ShotCreatedEvent extends Event
{
    public var msg :ShipShotMessage;

    public function ShotCreatedEvent (type :String, msg :ShipShotMessage)
    {
        super(type, false, false);
        this.msg = msg;
    }
}

}
