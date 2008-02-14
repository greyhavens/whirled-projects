package popcraft.battle.geom {
    
public class CollisionGridCell
{
    public var listHead :CollisionObject;
    
    public var x :int;
    public var y :int;
    
    public function CollisionGridCell (x :int, y :int)
    {
        this.x = x;
        this.y = y;
    }

}

}