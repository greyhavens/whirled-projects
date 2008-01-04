package ghostbusters.fight.core.util {

import ghostbusters.fight.core.*;

public class Collision
{
    /** Returns true if the two circles intersect. */
    public static function circlesIntersect (
        center1 :Vector2,
        radius1 :Number,
        center2 :Vector2,
        radius2 :Number) :Boolean
    {
        var maxDistSquared :Number = ((radius1 + radius2) * (radius1 + radius2));
        var dVec :Vector2 = Vector2.subtract(center1, center2);

        return (dVec.lengthSquared <= maxDistSquared);
    }
}

}
