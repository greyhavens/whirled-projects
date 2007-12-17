package popcraft.battle {

import core.util.NumRange;

public class UnitAttack
{
    public var damageType :uint;
    public var damageRange :NumRange;
    public var targetClassMask :uint;
    public var cooldown :Number;

    public function UnitAttack (damageType :uint, damageRange :NumRange, targetClassMask :uint, cooldown :Number)
    {
        this.damageType = damageType;
        this.damageRange = damageRange;
        this.targetClassMask = targetClassMask;
        this.cooldown = cooldown;
    }

    public function isValidTargetClass(targetClass :uint) :Boolean
    {
        return ((targetClassMask & targetClass) == targetClass);
    }
}

}
