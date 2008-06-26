package popcraft.battle {

import flash.events.Event;

public class UnitCreatedEvent extends Event
{
    public static const UNIT_CREATED :String = "UnitCreated";

    public var unitType :int;
    public var owningPlayerIndex :int;

    public function UnitCreatedEvent (unitType :int, owningPlayerIndex :int)
    {
        super(UNIT_CREATED, false, false);
        this.unitType = unitType;
        this.owningPlayerIndex = owningPlayerIndex;
    }

}

}
