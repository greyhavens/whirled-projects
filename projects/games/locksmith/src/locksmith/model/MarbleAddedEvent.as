//
// $Id$

package locksmith.model {

import flash.events.Event;

public class MarbleAddedEvent extends Event
{
    public function MarbleAddedEvent (marble :Marble, position :int)
    {
        super(RingManager.MARBLE_ADDED);
        _marble = marble;
        _position = position;
    }

    public function get marble () :Marble
    {
        return _marble;
    }

    public function get position () :int
    {
        return _position;
    }

    protected var _marble :Marble;
    protected var _position :int;
}
}
