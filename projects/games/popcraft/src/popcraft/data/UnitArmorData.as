package popcraft.data {

import com.threerings.util.Assert;

import popcraft.*;
import popcraft.util.*;

/**
 * UnitArmor is a damage filter that modifies the effects of an attack before it's applied to a unit.
 * All units have a UnitArmor.
 */
public class UnitArmorData
{
    public function UnitArmorData (armorArray :Array)
    {
        _armor = armorArray;
    }

    public function getWeaponDamage (weapon :UnitWeaponData) :Number
    {
        return this.getDamage(weapon.damageType, weapon.damageRange.next());
    }

    public function getDamage (damageType :uint, baseDamage :Number) :Number
    {
        var armorValue :Number = (damageType < _armor.length ? _armor[damageType] : 1);
        return (baseDamage * armorValue);
    }

    public static function fromXml (xml :XML) :UnitArmorData
    {
        var armorArray :Array = [];
        for (var i :int = 0; i < Constants.DAMAGE_TYPE_NAMES.length; ++i) {
            armorArray.push(Number(0));
        }

        for each (var damageNode :XML in xml.Damage) {
            var type :uint = XmlReader.getAttributeAsEnum(xml, "type", Constants.DAMAGE_TYPE_NAMES);
            var scale :Number = XmlReader.getAttributeAsNumber(xml, "scale");
            armorArray[type] = scale;
        }

        return new UnitArmorData(armorArray);
    }

    protected var _armor :Array = [];
}

}
