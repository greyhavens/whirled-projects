package popcraft.battle {

import com.whirled.contrib.simplegame.util.*;

/** Encapsulates immutable data about a particular type of Unit. */
public class UnitData
{
    public var name :String;
    public var resourceCosts :Array;

    // movement variables
    public var baseMoveSpeed :Number = 0;

    public var maxHealth :int;
    public var armor :UnitArmor;
    public var weapons :Array;

    public var collisionRadius :Number = 0;
    public var detectRadius :Number = 0;
    public var loseInterestRadius :Number = 0;

    public function getResourceCost (resourceType :uint) :int
    {
        return this.resourceCosts[resourceType];
    }
}

}
