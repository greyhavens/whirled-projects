package popcraft.battle {

import com.whirled.contrib.core.util.NumRange;

public class UnitAttack
{
    public var damageType :uint;
    public var damageRange :NumRange;
    public var targetClassMask :uint;
    public var cooldown :Number;
    public var attackRadius :Number;

    public function UnitAttack (
        damageType :uint,
        damageRange :NumRange,
        targetClassMask :uint,
        cooldown :Number,
        attackRadius :Number)
    {
        this.damageType = damageType;
        this.damageRange = damageRange;
        this.targetClassMask = targetClassMask;
        this.cooldown = cooldown;
        this.attackRadius = attackRadius;
    }

    public function isValidTargetClass(targetClass :uint) :Boolean
    {
        return ((targetClassMask & targetClass) == targetClass);
    }
}

}
