package popcraft.data {

import com.whirled.contrib.simplegame.util.*;

import popcraft.*;
import popcraft.util.*;

public class UnitWeaponData
{
    // General weapon options
    public var damageType :uint;
    public var initialWarmup :Number = 0;
    public var cooldown :Number = 0;
    public var maxAttackDistance :Number = 0;
    public var damageRange :NumRange;

    // Ranged weapon options
    public var isRanged :Boolean;
    public var missileSpeed :Number = 0; // pixels/second

    // AOE weapon options
    public var isAOE :Boolean;
    public var aoeRadius :Number = 0;
    public var aoeDamageFriendlies :Boolean;
    public var aoeMaxDamage :Number;

    public function get aoeRadiusSquared () :Number
    {
        return aoeRadius * aoeRadius;
    }

    public function clone () :UnitWeaponData
    {
        var theClone :UnitWeaponData = new UnitWeaponData();

        theClone.damageType = damageType;
        theClone.initialWarmup = initialWarmup;
        theClone.cooldown = cooldown;
        theClone.maxAttackDistance = maxAttackDistance;
        theClone.damageRange = damageRange.clone();

        theClone.isRanged = isRanged;
        theClone.missileSpeed = missileSpeed;

        theClone.isAOE = isAOE;
        theClone.aoeRadius = aoeRadius;
        theClone.aoeDamageFriendlies = aoeDamageFriendlies;
        theClone.aoeMaxDamage = aoeMaxDamage;

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :UnitWeaponData = null) :UnitWeaponData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var weapon :UnitWeaponData = (useDefaults ? inheritFrom : new UnitWeaponData());

        weapon.damageType = XmlReader.getAttributeAsEnum(xml, "damageType", Constants.DAMAGE_TYPE_NAMES, (useDefaults ? inheritFrom.damageType : undefined));
        weapon.initialWarmup = XmlReader.getAttributeAsNumber(xml, "initialWarmup", (useDefaults ? inheritFrom.initialWarmup : 0));
        weapon.cooldown = XmlReader.getAttributeAsNumber(xml, "cooldown", (useDefaults ? inheritFrom.cooldown : 0.1));
        weapon.maxAttackDistance = XmlReader.getAttributeAsNumber(xml, "maxAttackDistance", (useDefaults ? inheritFrom.maxAttackDistance : 0));

        var damageMin :Number = XmlReader.getAttributeAsNumber(xml, "damageMin", (useDefaults ? inheritFrom.damageRange.min : undefined));
        var damageMax :Number = XmlReader.getAttributeAsNumber(xml, "damageMax", (useDefaults ? inheritFrom.damageRange.max : undefined));
        weapon.damageRange = new NumRange(damageMin, damageMax, Rand.STREAM_GAME);

        // ranged weapons
        weapon.isRanged = XmlReader.getAttributeAsBoolean(xml, "isRanged", (useDefaults ? inheritFrom.isRanged : false));
        if (weapon.isRanged) {
            weapon.missileSpeed = XmlReader.getAttributeAsNumber(xml, "missileSpeed", (useDefaults ? inheritFrom.missileSpeed : undefined));
        }

        // AOE weapons
        weapon.isAOE = XmlReader.getAttributeAsBoolean(xml, "isAOE", (useDefaults ? inheritFrom.isAOE : false));
        if (weapon.isAOE) {
            weapon.aoeRadius = XmlReader.getAttributeAsNumber(xml, "aoeRadius", (useDefaults ? inheritFrom.aoeRadius : undefined));
            weapon.aoeDamageFriendlies = XmlReader.getAttributeAsBoolean(xml, "aoeDamageFriendlies", (useDefaults ? inheritFrom.aoeDamageFriendlies : undefined));
            weapon.aoeMaxDamage = XmlReader.getAttributeAsNumber(xml, "aoeMaxDamage", (useDefaults ? inheritFrom.aoeMaxDamage : undefined));
        }

        return weapon;
    }
}

}
