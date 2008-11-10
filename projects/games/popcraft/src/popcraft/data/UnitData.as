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
    public var introText2 :String;
    public var resourceCosts :Array = [];

    public var baseMoveSpeed :Number = 0;
    public var hasRepulseForce :Boolean;

    public var survivesDaytime :Boolean;
    public var minHealth :int;
    public var maxHealth :int;
    public var armor :UnitArmorData = new UnitArmorData();
    public var weapon :UnitWeaponData;

    public var collisionRadius :Number = 0;
    public var detectRadius :Number = 0;
    public var loseInterestRadius :Number = 0;

    public function getResourceCost (resourceType :int) :int
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
        theClone.introText2 = introText2;
        theClone.resourceCosts = resourceCosts.slice();

        theClone.baseMoveSpeed = baseMoveSpeed;
        theClone.hasRepulseForce = hasRepulseForce;

        theClone.survivesDaytime = survivesDaytime;
        theClone.minHealth = minHealth;
        theClone.maxHealth = maxHealth;
        theClone.armor = armor.clone();
        theClone.weapon = weapon.clone();

        theClone.collisionRadius = collisionRadius;
        theClone.detectRadius = detectRadius;
        theClone.loseInterestRadius = loseInterestRadius;

        return theClone;
    }

    public static function fromXml (xml :XML, defaults :UnitData = null) :UnitData
    {
        var useDefaults :Boolean = (null != defaults);
        var data :UnitData = (useDefaults ? defaults : new UnitData());

        data.name = XmlReader.getStringAttr(xml, "type",
            (useDefaults ? defaults.name : undefined));
        data.displayName = XmlReader.getStringAttr(xml, "displayName",
            (useDefaults ? defaults.displayName : undefined));
        data.description = XmlReader.getStringAttr(xml, "description",
            (useDefaults ? defaults.description : undefined));
        data.introText = XmlReader.getStringAttr(xml, "introText",
            (useDefaults ? defaults.introText : undefined));
        data.introText2 = XmlReader.getStringAttr(xml, "introText2",
            (useDefaults ? defaults.introText2 : undefined));

        var resourceCostsNode :XML = xml.ResourceCosts[0];
        if (null != resourceCostsNode) {
            // don't inherit resource costs
            data.resourceCosts = [ 0, 0, 0, 0 ];
            for each (var resourceNode :XML in resourceCostsNode.Resource) {
                var resourceType :int = XmlReader.getEnumAttr(resourceNode, "type",
                    Constants.RESOURCE_NAMES);
                var cost :int = XmlReader.getUintAttr(resourceNode, "amount");
                data.resourceCosts[resourceType] = cost;
            }
        }

        data.baseMoveSpeed = XmlReader.getNumberAttr(xml, "baseMoveSpeed",
            (useDefaults ? defaults.baseMoveSpeed : undefined));
        data.hasRepulseForce = XmlReader.getBooleanAttr(xml, "hasRepulseForce",
            (useDefaults ? defaults.hasRepulseForce : undefined));
        data.survivesDaytime = XmlReader.getBooleanAttr(xml, "survivesDaytime",
            (useDefaults ? defaults.survivesDaytime : false));
        data.minHealth = XmlReader.getUintAttr(xml, "minHealth",
            (useDefaults ? defaults.minHealth : 0));
        data.maxHealth = XmlReader.getUintAttr(xml, "maxHealth",
            (useDefaults ? defaults.maxHealth : undefined));

        var armorNode :XML = xml.Armor[0];
        if (null != armorNode) {
            data.armor = UnitArmorData.fromXml(armorNode);
        }

        var weaponNode :XML = xml.Weapon[0];
        if (null != weaponNode) {
            data.weapon = UnitWeaponData.fromXml(weaponNode,
                (useDefaults ? defaults.weapon : null));
        }

        data.collisionRadius = XmlReader.getNumberAttr(xml, "collisionRadius",
            (useDefaults ? defaults.collisionRadius : undefined));
        data.detectRadius = XmlReader.getNumberAttr(xml, "detectRadius",
            (useDefaults ? defaults.detectRadius : undefined));
        data.loseInterestRadius = XmlReader.getNumberAttr(xml, "loseInterestRadius",
            (useDefaults ? defaults.loseInterestRadius : undefined));

        return data;
    }
}

}
