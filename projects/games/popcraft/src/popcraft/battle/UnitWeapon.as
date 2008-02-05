package popcraft.battle {

import com.whirled.contrib.core.util.NumRange;

public class UnitWeapon
{
    public static const TYPE_MELEE :uint = 0;
    public static const TYPE_MISSILE :uint = 1;
    
    public var weaponType :uint;
    public var damageType :uint;
    public var damageRange :NumRange;
    public var targetClassMask :uint;
    public var cooldown :Number;
    public var maxAttackDistance :Number;
    public var missileSpeed :Number; // pixels/second - only meaningful for missiles

    public function UnitWeapon (
        weaponType :uint,
        damageType :uint,
        damageRange :NumRange,
        targetClassMask :uint,
        cooldown :Number,
        maxAttackDistance :Number,
        missileSpeed :Number)
    {
        this.weaponType = weaponType;
        this.damageType = damageType;
        this.damageRange = damageRange;
        this.targetClassMask = targetClassMask;
        this.cooldown = cooldown;
        this.maxAttackDistance = maxAttackDistance;
        this.missileSpeed = missileSpeed;
    }

    public function isValidTargetClass(targetClass :uint) :Boolean
    {
        return ((targetClassMask & targetClass) == targetClass);
    }
}

}
