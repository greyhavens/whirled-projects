package sprites {

import mx.core.IFlexDisplayObject;
    
/**
 * Encapsulates animations for the different critter states, and their dimension info.
 */
public class CritterAssets extends UnitAssets
{
    public static const WALK_RIGHT :int = 0;
    public static const WALK_UP :int = 1;
    public static const WALK_LEFT :int = 2;
    public static const WALK_DOWN :int = 3;

    public var right :IFlexDisplayObject;
    public var up :IFlexDisplayObject;
    public var left :IFlexDisplayObject;
    public var down :IFlexDisplayObject;
    
    public function getWalkAsset (walkDirection :int) :IFlexDisplayObject
    {
        switch (walkDirection) {
        case WALK_RIGHT: return right;
        case WALK_UP: return up;
        case WALK_LEFT: return left;
        case WALK_DOWN: return down;
        default: throw new Error("Invalid walk direction: " + walkDirection);
        }
    }
}
}
