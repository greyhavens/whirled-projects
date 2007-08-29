package {

/**
 * Tower definition contains information sufficient to create or display a new tower of specified
 * type at specified location. Tower locations are rectangular subsets of the board; this class
 * defines some convenient helpers for iterating over all cells contained inside a location.
 */
public class TowerDef
{
    public var type :int;
    public var x :int;
    public var y :int;
    public var width :int;
    public var height :int;

    public function TowerDef (x :int, y :int, type :int)
    {
        this.type = type;
        this.x = x;
        this.y = y;

        switch(type) {
        case Tower.TYPE_SIMPLE:
            this.width = this.height = 2;
            break;
        default:
            this.width = this.height = 1;
        }
    }

    public function equals (def :TowerDef) :Boolean
    {
        return (this.type == def.type) && (this.x == def.x) && (this.y == def.y) &&
            (this.width == def.width) && (this.height == def.height);
    }
    
    public function copyFrom (def :TowerDef) :void
    {
        this.type = def.type;
        this.x = def.x;
        this.y = def.y;
        this.width = def.width;
        this.height = def.height;
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

    public function toString () :String
    {
        return "TowerDef: [" + type + " : " + x + ", " + y + " : " + width + "x" + height + "].";
    }
}
}
