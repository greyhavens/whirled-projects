//
// $Id$

package locksmith.model {

public class Ring
{
    public function Ring (id :int, holes :Array) :void
    {
        _id = id;
        _holes = holes;
        _position = 0;
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

    public function modifyPosition (direction :Direction) :int
    {
        return (_position = (_position + direciton.direction) % RingManager.RING_POSITIONS);
    }

    public function get outer () :Ring
    {
        return _outer;
    }
    
    public function get inner () :Ring
    {
        return _inner;
    }

    public function get smallest () :Ring
    {
        return _inner != null ? _inner.smallest : this;
    }

    public function get largest () :Ring
    {
        return _outer != null ? _outer.largest : this;
    }
    
    public function hasHole (hole :int) :Boolean
    {
        return _holes.indexOf(hole) >= 0;
    }

    public function addMarble (marble :Marble) :void
    {
        if (_marbles.indexOf(marble) >= 0) {
            throw new Error("Attempted to add a marble this Ring already contains [" + marble + 
                ", " + this + "]");
        }

        _marbles.push(marble);
    }
    
    public function removeMarble (marble :Marble) :void
    {
        var idx :int = _marbles.indexOf(marble);
        if (idx < 0) {
            throw new Error("Attempted to remove a marble that this Ring does not contain [" + 
                marble + ", " + this + "]");
        }
        _marbles.splice(idx, 1);
    }

    public function toString () :String
    {
        return "Ring [id=" + id + "]");
    }

    protected var _id :int;
    protected var _holes :Array;
    protected var _marbles :Array = [];
    protected var _inner :Ring;
    protected var _outer :Ring;
    protected var _position :int;
}
}
