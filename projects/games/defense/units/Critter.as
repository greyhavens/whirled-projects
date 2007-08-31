package units {
    
import flash.geom.Point;
    
public class Critter
{
    public static const TYPE_WEAK :int = 1;

    public var target :Point; // target position, in board units
    public var pos :Point;    // current position, in board units
    public var delta :Point;  // distance to target position
    public var vel :Point;    // current velocity, in board units per second
    
    public var maxvel :Number // max velocity (in board units per second, axis-independent)
    public var type :int;
    public var player :int;
    public var guid :int;
    
    public static function makeGuid () :int
    {
        return int(Math.random() * int.MAX_VALUE);
    }

    public function Critter (x :int, y :int, type :int, player :int)
    {
        this.pos = new Point(x, y);
        this.vel = new Point(0, 0);
        this.target = new Point(x, y);
        this.delta = new Point(0, 0);
        
        this.type = type;
        this.player = player;
        this.guid = makeGuid();

        this.maxvel = 1;
    }
}
}
