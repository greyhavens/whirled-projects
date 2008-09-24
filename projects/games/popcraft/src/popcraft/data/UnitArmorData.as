package popcraft.data {

import popcraft.*;
import popcraft.util.*;

/**
 * UnitArmor is a damage filter that modifies the effects of an attack before it's applied to a
 * unit. All units have a UnitArmor.
 */
public class UnitArmorData
{
    public var armor :Array = [];

    public function getWeaponDamage (weapon :UnitWeaponData) :Number
    {
        return this.getDamage(weapon.damageType, weapon.damageRange.next());
    }

    public function getDamage (damageType :int, baseDamage :Number) :Number
    {
        var armorValue :Number = (damageType < armor.length ? armor[damageType] : 1);
        return (baseDamage * armorValue);
    }

    public function clone () :UnitArmorData
    {
        var theClone :UnitArmorData = new UnitArmorData();
        theClone.armor = armor.slice();
        return theClone;
    }

    public static function fromXml (xml :XML) :UnitArmorData
    {
        var armorData :UnitArmorData = new UnitArmorData();

        if (null != xml) {
            for (var i :int = 0; i < Constants.DAMAGE_TYPE_NAMES.length; ++i) {
                armorData.armor.push(Number(0));
            }

            for each (var damageNode :XML in xml.Damage) {
                var type :int = XmlReader.getAttributeAsEnum(damageNode, "type",
                    Constants.DAMAGE_TYPE_NAMES);
                var scale :Number = XmlReader.getAttributeAsNumber(damageNode, "scale");
                armorData.armor[type] = scale;
            }
        }

        return armorData;
    }
}

}
