package popcraft.battle {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;

/**
 * UnitArmor is a damage filter that modifies the effects of an attack before it's applied to a unit.
 * All units have a UnitArmor.
 */
public class UnitArmor
{
    /**
     * Construct a new UnitArmor.
     * armorArray is an array of pairs of uints and Numbers - damage types and damage modifiers.
     */
    public function UnitArmor (armorArray :Array = null)
    {
        if (null != armorArray) {

            // array length must be divisible by 2
            Assert.isTrue((armorArray.length % 2) == 0);

            var n :int = armorArray.length;
            for (var i :int = 0; i < n; i += 2) {
                var damageType :uint = armorArray[i];
                var damageMultiplier :Number = armorArray[int(i + 1)];

                _armor.put(damageType, damageMultiplier);
            }
        }
    }

    public function getWeaponDamage (weapon :UnitWeaponData) :Number
    {
        return this.getDamage(weapon.damageType, weapon.damageRange.next());
    }

    public function getDamage (damageType :uint, baseDamage :Number) :Number
    {
        var armorValue :* = _armor.get(damageType);
        var damageMultiplier :Number = (undefined !== armorValue ? armorValue : 1);

        return (baseDamage * damageMultiplier);
    }

    protected var _armor :HashMap = new HashMap();
}

}
