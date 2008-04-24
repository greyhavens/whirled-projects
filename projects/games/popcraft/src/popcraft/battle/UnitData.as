package popcraft.battle {

import com.whirled.contrib.simplegame.util.*;

import popcraft.*;
import popcraft.util.*;

/** Encapsulates immutable data about a particular type of Unit. */
public class UnitData
{
    public var name :String = "";
    public var displayName :String = "";
    public var description :String = "";
    public var resourceCosts :Array = [ 0, 0, 0, 0 ];

    // movement variables
    public var baseMoveSpeed :Number = 0;

    public var maxHealth :int;
    public var armor :UnitArmorData;
    public var weapon :UnitWeaponData;

    public var collisionRadius :Number = 0;
    public var detectRadius :Number = 0;
    public var loseInterestRadius :Number = 0;

    public function getResourceCost (resourceType :uint) :int
    {
        return this.resourceCosts[resourceType];
    }

    public static function fromXml (xml :XML) :UnitData
        // throws XmlReadError
    {
        var unitData :UnitData = new UnitData();
        unitData.name = XmlReader.getAttributeAsString(xml, "name");
        unitData.displayName = XmlReader.getAttributeAsString(xml, "displayName");
        unitData.description = XmlReader.getAttributeAsString(xml, "description");

        for each (var resourceNode :XML in xml.ResourceCosts.Resource) {
            var resourceType :uint = XmlReader.getAttributeAsEnum(resourceNode, "type", Constants.RESOURCE_NAMES);
            var cost :int = XmlReader.getAttributeAsUint(resourceNode, "cost");
            unitData.resourceCosts[resourceType] = cost;
        }

        unitData.baseMoveSpeed = XmlReader.getAttributeAsNumber(xml, "baseMoveSpeed");
        unitData.maxHealth = XmlReader.getAttributeAsInt(xml, "maxHealth");

        unitData.weapon = UnitWeaponData.fromXml(xml.Weapon);

        unitData.collisionRadius = XmlReader.getAttributeAsNumber(xml, "collisionRadius");
        unitData.detectRadius = XmlReader.getAttributeAsNumber(xml, "detectRadius");
        unitData.loseInterestRadius = XmlReader.getAttributeAsNumber(xml, "loseInterestRadius");

        return unitData;
    }
}

}
