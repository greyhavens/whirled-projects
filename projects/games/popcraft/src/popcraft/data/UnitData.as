package popcraft.data {

import com.whirled.contrib.simplegame.util.*;

import popcraft.*;
import popcraft.util.*;

/** Encapsulates immutable data about a particular type of Unit. */
public class UnitData
{
    public var name :String;
    public var displayName :String;
    public var description :String;
    public var introText :String;
    public var resourceCosts :Array = [];

    public var baseMoveSpeed :Number = 0;
    public var hasRepulseForce :Boolean;

    public var maxHealth :int;
    public var armor :UnitArmorData = new UnitArmorData();
    public var weapon :UnitWeaponData;

    public var collisionRadius :Number = 0;
    public var detectRadius :Number = 0;
    public var loseInterestRadius :Number = 0;

    public function getResourceCost (resourceType :uint) :int
    {
        return this.resourceCosts[resourceType];
    }

    public function clone () :UnitData
    {
        var theClone :UnitData = new UnitData();

        theClone.name = name;
        theClone.displayName = displayName;
        theClone.description = description;
        theClone.introText = introText;
        theClone.resourceCosts = resourceCosts.slice();

        theClone.baseMoveSpeed = baseMoveSpeed;
        theClone.hasRepulseForce = hasRepulseForce;

        theClone.maxHealth = maxHealth;
        theClone.armor = armor.clone();
        theClone.weapon = weapon.clone();

        theClone.collisionRadius = collisionRadius;
        theClone.detectRadius = detectRadius;
        theClone.loseInterestRadius = loseInterestRadius;

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :UnitData = null) :UnitData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var unitData :UnitData = (useDefaults ? inheritFrom : new UnitData());

        unitData.name = XmlReader.getAttributeAsString(xml, "type", (useDefaults ? inheritFrom.name : undefined));
        unitData.displayName = XmlReader.getAttributeAsString(xml, "displayName", (useDefaults ? inheritFrom.displayName : undefined));
        unitData.description = XmlReader.getAttributeAsString(xml, "description", (useDefaults ? inheritFrom.description : undefined));
        unitData.introText = XmlReader.getAttributeAsString(xml, "introText", (useDefaults ? inheritFrom.introText : undefined));

        var resourceCostsNode :XML = xml.ResourceCosts[0];
        if (null != resourceCostsNode) {
            // don't inherit resource costs
            unitData.resourceCosts = [ 0, 0, 0, 0 ];
            for each (var resourceNode :XML in resourceCostsNode.Resource) {
                var resourceType :uint = XmlReader.getAttributeAsEnum(resourceNode, "type", Constants.RESOURCE_NAMES);
                var cost :int = XmlReader.getAttributeAsUint(resourceNode, "amount");
                unitData.resourceCosts[resourceType] = cost;
            }
        }

        unitData.baseMoveSpeed = XmlReader.getAttributeAsNumber(xml, "baseMoveSpeed", (useDefaults ? inheritFrom.baseMoveSpeed : undefined));
        unitData.hasRepulseForce = XmlReader.getAttributeAsBoolean(xml, "hasRepulseForce", (useDefaults ? inheritFrom.hasRepulseForce : undefined));
        unitData.maxHealth = XmlReader.getAttributeAsInt(xml, "maxHealth", (useDefaults ? inheritFrom.maxHealth : undefined));

        var armorNode :XML = xml.Armor[0];
        if (null != armorNode) {
            unitData.armor = UnitArmorData.fromXml(armorNode);
        }

        var weaponNode :XML = xml.Weapon[0];
        if (null != weaponNode) {
            unitData.weapon = UnitWeaponData.fromXml(weaponNode, (useDefaults ? inheritFrom.weapon : null));
        }

        unitData.collisionRadius = XmlReader.getAttributeAsNumber(xml, "collisionRadius", (useDefaults ? inheritFrom.collisionRadius : undefined));
        unitData.detectRadius = XmlReader.getAttributeAsNumber(xml, "detectRadius", (useDefaults ? inheritFrom.detectRadius : undefined));
        unitData.loseInterestRadius = XmlReader.getAttributeAsNumber(xml, "loseInterestRadius", (useDefaults ? inheritFrom.loseInterestRadius : undefined));

        return unitData;
    }
}

}
