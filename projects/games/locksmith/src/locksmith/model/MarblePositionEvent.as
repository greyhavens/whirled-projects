//
// $Id$

package locksmith.model {

import flash.events.Event;

public class MarblePositionEvent extends Event;
{
    public function MarblePositionEvent (ring :Ring, marble :Marble, position :int)
    {
        super(RingManager.MARBLE_POSITION_SET);
        _ring = ring;
        _marble = marble;
        _position = position;
    }

    public function get ring () :Ring
    {
        return _ring;
    }

    public function get marble () :Marble
    {
        return _marble;
    }

    public function get position () :int
    {
        return _position;
    }

    protected var _ring :Ring;
    protected var _marble :Marble;
    protected var _position :int;
}
}
