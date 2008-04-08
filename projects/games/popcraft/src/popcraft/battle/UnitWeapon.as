package popcraft.battle {

import com.whirled.contrib.simplegame.util.NumRange;

public class UnitWeapon
{
    // General weapon options
    public var isRanged :Boolean;
    public var isAOE :Boolean;
    public var damageType :uint;
    public var damageRange :NumRange;
    public var targetClassMask :uint;
    public var cooldown :Number = 0;
    public var maxAttackDistance :Number = 0;

    // Ranged weapon options
    public var missileSpeed :Number = 0; // pixels/second

    // AOE weapon options
    public var aoeRadius :Number = 0;
    public var aoeAnimationName :String;
    public var aoeDamageFriendlies :Boolean;

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
