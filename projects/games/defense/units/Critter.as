package units {
    
import flash.geom.Point;
    
public class Critter extends Unit
{
    public static const TYPE_WEAK :int = 1;

    public var target :Point; // target position, in board units
    public var delta :Point;  // distance to target position
    public var vel :Point;    // current velocity, in board units per second
    public var maxvel :Number // max velocity (in board units per second, axis-independent)
    public var type :int;
    
    public function Critter (x :int, y :int, type :int, player :int)
    {
        super(player, x, y, 1, 1);

        this.vel = new Point(0, 0);
        this.target = new Point(x, y);
        this.delta = new Point(0, 0);
        
        this.type = type;
        this.maxvel = 1;
    }

    // position of the sprite centroid in screen coordinates
    override public function get centroidx () :Number
    {
        return Board.SQUARE_WIDTH * (pos.x + size.x / 2);
    }

    override public function get centroidy () :Number
    {
        return Board.SQUARE_HEIGHT * (pos.y + size.y / 2);
    }

}
}
