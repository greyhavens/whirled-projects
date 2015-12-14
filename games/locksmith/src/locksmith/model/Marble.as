//
// $Id$

package locksmith.model {

public class Marble 
{
    public function Marble (id :int, player :Player)
    {
        _id = id;
        _player = player;
    }

    public function get id () :int
    {
        return _id;
    }

    public function get player () :Player
    {
        return _player;
    }

    protected var _id :int;
    protected var _player :Player;
}
}
