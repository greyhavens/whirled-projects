package units {

/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 * Towers occupy rectangular subsets of the board.
 */
public class Tower
{
    public static const NO_PLAYER :int = -1;
    
    public static const TYPE_SIMPLE :int = 1;

    public var x :int;
    public var y :int;
    public var player :int;
    
    protected var _guid :int;
    protected var _type :int;
    protected var _width :int;
    protected var _height :int;

    public static function makeGuid () :int
    {
        return int(Math.random() * int.MAX_VALUE);
    }
    
    public function Tower (x :int, y :int, type :int, player :int, guid :int)
    {
        this.x = x;
        this.y = y;
        this.player = player;

        _guid = guid;

        updateType(type);
    }

    public function get type () :int
    {
        return _type;
    }

    public function get width () :int
    {
        return _width;
    }

    public function get height () :int
    {
        return _height;
    }

    public function get guid () :int
    {
        return _guid;
    }
    
    public function equals (t :Tower) :Boolean
    {
        return t.guid == this.guid;
    }
    
    public function updateType (value :int) :void
    {
        _type = value;
        switch(_type) {
        case Tower.TYPE_SIMPLE:
            _width = _height = 2;
            break;
        default:
            _width = _height = 1;
        }
    }

    /**
     * Iterates the specified function over all cells contained inside the location.
     * Function should be of the type: function (x :int, y :int) :void { }
     */
    public function forEach (fn :Function) :void
    {
        var right :int = x + width;
        var bottom :int = y + height;
        for (var xx :int = x; xx < right; xx++) {
            for (var yy :int = y; yy < bottom; yy++) {
                fn(xx, yy);
            }
        }
    }

    /**
     * Iterates the specified function over all cells contained inside the location, and collects
     * all results into an array.
     * Function should be of the type: function (x :int, y :int) :* { }
     */
    public function map (fn :Function) :Array
    {
        var results :Array = new Array;
        var right :int = x + width;
        var bottom :int = y + height;
        for (var xx :int = x; xx < right; xx++) {
            for (var yy :int = y; yy < bottom; yy++) {
                results.push(fn(xx, yy));
            }
        }
        return results;
    }

    public function serialize () :Object
    {
        return { x: this.x, y: this.y, type: this.type, player: this.player, guid: this.guid };
    }

    public static function deserialize (obj :Object) :Tower
    {
        return new Tower(obj.x, obj.y, obj.type, obj.player, obj.guid);
    }

    public function toString () :String
    {
        return "Tower [" + _type + ": " + x + ", " + y + " : " + _width + "x" + _height +
            ", player: " + player + ", guid: " + _guid + "].";
    }
    
}
}
