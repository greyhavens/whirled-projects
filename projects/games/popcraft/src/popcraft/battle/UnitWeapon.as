package popcraft.battle {

import com.whirled.contrib.simplegame.util.NumRange;

public class UnitWeapon
{
    public var isRanged :Boolean;
    public var isAOE :Boolean;
    public var damageType :uint;
    public var damageRange :NumRange;
    public var targetClassMask :uint;
    public var cooldown :Number;
    public var maxAttackDistance :Number;
    public var missileSpeed :Number; // pixels/second - only meaningful for missiles
    public var damageRadius :Number; // only meaningful for AOE

    public function UnitWeapon (
        isRanged :Boolean,
        isAOE :Boolean,
        damageType :uint,
        damageRange :NumRange,
        targetClassMask :uint,
        cooldown :Number,
        maxAttackDistance :Number,
        missileSpeed :Number,
        damageRadius :Number)
    {
        this.isRanged = isRanged;
        this.isAOE = isAOE;
        this.damageType = damageType;
        this.damageRange = damageRange;
        this.targetClassMask = targetClassMask;
        this.cooldown = cooldown;
        this.maxAttackDistance = maxAttackDistance;
        this.missileSpeed = missileSpeed;
        this.damageRadius = damageRadius;
    }

    public function isValidTargetClass(targetClass :uint) :Boolean
    {
        return ((targetClassMask & targetClass) == targetClass);
    }
}

}
