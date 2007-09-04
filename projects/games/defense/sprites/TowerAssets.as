package sprites {

import mx.core.IFlexDisplayObject;
    
/**
 * Encapsulates animations for the different tower states, and their dimension info.
 */
public class TowerAssets
{
    public var base :IFlexDisplayObject;
    public var rightAttack :IFlexDisplayObject; // todo
    public var upAttack :IFlexDisplayObject;
    public var leftAttack :IFlexDisplayObject;
    public var downAttack :IFlexDisplayObject;

    public var screenHeight :Number;
    public var screenWidth :Number;
}
}
