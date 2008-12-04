//
// $Id$

package locksmith.model {

import com.threerings.util.ArrayUtil;

public class Ring
{
    public function Ring (id :int, holes :Array) :void
    {
        _id = id;
        _holes = holes;
        _position = 0;

        _marbles = ArrayUtil.create(RingManager.RING_POSITIONS, null);
    }

    public function get id () :int
    {
        return _id;
    }

    public function get holes () :Array
    {
        return _holes;
    }

    public function get position () :int
    {
        return _position;
    }

    public function modifyPosition (direction :RotationDirection) :int
    {
        return (_position = (_position + direction.direction) % RingManager.RING_POSITIONS);
    }

    public function setPosition (position :int) :RotationDirection
    {
        if (Math.abs(_position - position) != 1) {
            throw new ArgumentError("The new position must be 1 off from current position " +
                "[current=" + _position + ", new=" + position + "]");
        }

        var direction :RotationDirection = 
            RotationDirection.determineDirection(position - _position);
        _position = position;
        return direction;
    }

    public function get outer () :Ring
    {
        return _outer;
    }

    public function set outer (value :Ring) :void
    {
        _outer = value;
    }
    
    public function get inner () :Ring
    {
        return _inner;
    }

    public function set inner (value :Ring) :void
    {
        _inner = value;
    }

    public function get smallest () :Ring
    {
        return _inner != null ? _inner.smallest : this;
    }

    public function get largest () :Ring
    {
        return _outer != null ? _outer.largest : this;
    }
    
    /**
     * Returns true if the position exists as a valid hole on this Ring, and there is not currently
     * A Marble in it.  Not the exact inverse of positionContainsMarble().  For a position that is
     * not valid on this Ring, both functions will return false.
     */
    public function positionOpen (position :int) :void
    {
        var localPosition :int = globalToLocal(position);
        return _holes.indexOf(localPosition) >= 0 && _marbles[localPosition] == null;
    }

    /**
     * Returns true of the position contains a marble.  Not the exact inverse of positionOpen().
     * For a position that is not valid on this Ring, both functions will return false.
     */
    public function positionContainsMarble (position :int) :void
    {
        var localPosition :int = globalToLocal(position);
        return _marbles[localPosition] == null;
    }

    public function addMarble (position :int, marble :Marble) :void
    {
        if (_marbles.indexOf(marble) >= 0) {
            throw new Error("Attempted to add a marble this Ring already contains [" + marble + 
                ", " + this + "]");
        }

        if (!positionOpen(position)) {
            throw new Error("Attemted to add a marble to a position that is not open [" + 
                marble + ", " + position + ", " + this + "]");
        }

        _marbles[globalToLocal(position)] = marble;
    }

    public function removeMarbleIn (position :int) :Marble
    {
        if (!positionContainsMarble(position))) {
            throw new Error("Asked to remove a marble from an empty position [" + position + ", " +
                this + "]");
        }

        var localPosition :int = globalToLocal(position);
        var marble :Marble = _marble[localPosition] as Marble;
        _marble[localPosition] = null;
        return marble;
    }

    public function toString () :String
    {
        return "Ring [id=" + id + "]");
    }

    protected function globalToLocal (position :int) :int
    {
        return (position + _position) % RingManager.RING_POSITIONS;
    }

    protected var _id :int;
    protected var _holes :Array;
    protected var _marbles :Array;
    protected var _inner :Ring;
    protected var _outer :Ring;
    protected var _position :int;
}
}
