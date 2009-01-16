package flashmob {

public class Rect3D
{
    public var x :Number;
    public var y :Number;
    public var z :Number;
    public var width :Number;
    public var height :Number;
    public var depth :Number;

    public function Rect3D (x :Number = 0, y :Number = 0, z :Number = 0, width :Number = 0,
                            height :Number = 0, depth :Number = 0)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.width = width;
        this.height = height;
        this.depth = depth;
    }
}

}
