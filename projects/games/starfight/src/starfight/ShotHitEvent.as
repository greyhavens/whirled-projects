package starfight {

import flash.events.Event;

public class ShotHitEvent extends Event
{
    public var x :Number;
    public var y :Number;

    public function ShotHitEvent (x :Number, y :Number)
    {
        super(Shot.HIT, false, false);
        this.x = x;
        this.y = y;
    }

}

}
