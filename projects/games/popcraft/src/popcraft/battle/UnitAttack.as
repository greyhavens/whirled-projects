package popcraft.battle {

import core.util.NumRange;

public class UnitAttack
{
    public var type :uint;
    public var damageRange :NumRange;

    public function UnitAttack (type :uint, damageRange :NumRange)
    {
        this.type = type;
        this.damageRange = damageRange;
    }
}

}
