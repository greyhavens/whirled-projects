package popcraft.battle {

import com.whirled.contrib.simplegame.util.NumRange;

public class UnitWeapon
{
    public var isRanged :Boolean;
    public var isAOE :Boolean;
    public var damageType :uint;
    public var damageRange :NumRange;
    public var targetClassMask :uint;
    public var cooldown :Number = 0;
    public var maxAttackDistance :Number = 0;
    public var missileSpeed :Number = 0; // pixels/second - only meaningful for missiles
    public var aoeRadius :Number = 0; // only meaningful for AOE

    public function get aoeRadiusSquared () :Number
    {
        return aoeRadius * aoeRadius;
    }

    public function isValidTargetClass(targetClass :uint) :Boolean
    {
        return ((targetClassMask & targetClass) == targetClass);
    }
}

}
