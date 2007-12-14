package popcraft.battle {

import core.util.NumRange;

public class UnitAttack
{
    public var type :uint;
    public var damageRange :NumRange;
    public var targetClassMask :uint;

    public function UnitAttack (type :uint, damageRange :NumRange, targetClassMask :uint)
    {
        this.type = type;
        this.damageRange = damageRange;
        this.targetClassMask = targetClassMask;
    }

    public function isValidTargetClass(targetClass :uint) :Boolean
    {
        return ((targetClassMask & targetClass) == targetClass);
    }
}

}
