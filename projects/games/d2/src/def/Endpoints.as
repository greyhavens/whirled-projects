package def {

import flash.geom.Point;
    
/**
 * Helper class represents start and end points for enemies.
 */
public class Endpoints {
    
    public var start :Point;
    public var target :Point;

    public function Endpoints (startx :Number, starty :Number, targetx :Number, targety :Number)
    {
        start = new Point(startx, starty);
        target = new Point(targetx, targety);
    }

    public function toString () :String {
        return "Endpoints [ " + start + " -> " + target + " ]";
    }
}
}
