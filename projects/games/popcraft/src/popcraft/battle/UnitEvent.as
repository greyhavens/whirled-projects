package popcraft.battle {

import flash.events.Event;

public class UnitEvent extends Event
{
    public static const ATTACKED :String = "Attacked";

    public var data :*;

    public function UnitEvent (type :String, data :*)
    {
        super(type, false, false);
        this.data = data;
    }

}

}
