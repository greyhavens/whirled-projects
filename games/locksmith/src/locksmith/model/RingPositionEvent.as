//
// $Id$

package locksmith.model {

import flash.events.Event;

public class RingPositionEvent extends Event 
{
    public function RingPositionEvent (ring :Ring, direction :RotationDirection)
    {
        super(RingManager.RING_POSITION_SET);
        _ring = ring;
        _direction = direction;
    }

    public function get ring () :Ring
    {
        return _ring;
    }

    public function get direction () :RotationDirection
    {
        return _direction;
    }

    protected var _ring :Ring;
    protected var _direction :RotationDirection;
}
}
