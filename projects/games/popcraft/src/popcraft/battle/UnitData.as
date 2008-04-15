package popcraft.battle {

import com.whirled.contrib.simplegame.util.*;

/** Encapsulates immutable data about a particular type of Unit. */
public class UnitData
{
    public var name :String = "";
    public var displayName :String = "";
    public var description :String = "";
    public var resourceCosts :Array = [];
    public var trainingTime :Number = 0;

    // movement variables
    public var baseMoveSpeed :Number = 0;

    public var maxHealth :int;
    public var armor :UnitArmor;
    public var weapon :UnitWeapon;

    public var collisionRadius :Number = 0;
    public var detectRadius :Number = 0;
    public var loseInterestRadius :Number = 0;

    public function getResourceCost (resourceType :uint) :int
    {
        return this.resourceCosts[resourceType];
    }
}

}
