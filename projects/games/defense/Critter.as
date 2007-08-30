package
{

public class Critter
{
    public static const TYPE_WEAK :int = 1;

    public var x :int;
    public var y :int;
    public var dx :int;
    public var dy :int;
    public var type :int;
    public var player :int;
    public var guid :int;
    
    public static function makeGuid () :int
    {
        return int(Math.random() * int.MAX_VALUE);
    }

    public function Critter (x :int, y :int, type :int, player :int)
    {
        this.x = x;
        this.y = y;
        this.dx = this.dy = 0;
        this.type = type;
        this.player = player;
        this.guid = makeGuid();
    }
}
}
