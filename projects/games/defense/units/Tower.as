package units {

/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 */
public class Tower
{
    public static const NO_PLAYER :int = -1;
    
    public static const TYPE_SIMPLE :int = 1;

    public static function makeGuid () :int
    {
        return int(Math.random() * int.MAX_VALUE);
    }
    
    public function Tower (def :TowerDef, player :int, guid :int)
    {
        _def = def; 
        _player = player;
        _guid = guid
    }

    public function get guid () :int
    {
        return _guid;
    }
    
    public function get def () :TowerDef
    {
        return _def;
    }

    public function set def (newdef :TowerDef) :void
    {
        _def.copyFrom(newdef);
    }

    public function get player () :int
    {
        return _player;
    }

    public function toString () :String
    {
        return "Tower [player: " + _player + ", guid: " + _guid + ", def: " + _def + "].";
    }
    
    protected var _player :int;
    protected var _def :TowerDef;
    protected var _guid :int;
}
}
