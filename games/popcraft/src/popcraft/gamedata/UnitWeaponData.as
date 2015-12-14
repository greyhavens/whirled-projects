//
// $Id$

package popcraft.gamedata {

import com.threerings.flashbang.util.*;
import com.threerings.util.XmlUtil;

import popcraft.*;
import popcraft.util.*;

public class UnitWeaponData
{
    // General weapon options
    public var damageType :int;
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

    public static function fromXml (xml :XML, defaults :UnitWeaponData = null) :UnitWeaponData
    {
        var useDefaults :Boolean = (null != defaults);

        var data :UnitWeaponData = (useDefaults ? defaults : new UnitWeaponData());

        data.damageType = XmlUtil.getStringArrayAttr(xml, "damageType",
            Constants.DAMAGE_TYPE_NAMES, (useDefaults ? defaults.damageType : undefined));
        data.initialWarmup = XmlUtil.getNumberAttr(xml, "initialWarmup",
            (useDefaults ? defaults.initialWarmup : 0));
        data.cooldown = XmlUtil.getNumberAttr(xml, "cooldown",
            (useDefaults ? defaults.cooldown : 0.1));
        data.maxAttackDistance = XmlUtil.getNumberAttr(xml, "maxAttackDistance",
            (useDefaults ? defaults.maxAttackDistance : 0));

        var damageMin :Number = XmlUtil.getNumberAttr(xml, "damageMin",
            (useDefaults ? defaults.damageRange.min : undefined));
        var damageMax :Number = XmlUtil.getNumberAttr(xml, "damageMax",
            (useDefaults ? defaults.damageRange.max : undefined));
        data.damageRange = new NumRange(damageMin, damageMax, Rand.STREAM_GAME);

        // ranged weapons
        data.isRanged = XmlUtil.getBooleanAttr(xml, "isRanged",
            (useDefaults ? defaults.isRanged : false));
        if (data.isRanged) {
            data.missileSpeed = XmlUtil.getNumberAttr(xml, "missileSpeed",
                (useDefaults ? defaults.missileSpeed : undefined));
        }

        // AOE weapons
        data.isAOE = XmlUtil.getBooleanAttr(xml, "isAOE",
            (useDefaults ? defaults.isAOE : false));
        if (data.isAOE) {
            data.aoeRadius = XmlUtil.getNumberAttr(xml, "aoeRadius",
                (useDefaults ? defaults.aoeRadius : undefined));
            data.aoeDamageFriendlies = XmlUtil.getBooleanAttr(xml, "aoeDamageFriendlies",
                (useDefaults ? defaults.aoeDamageFriendlies : undefined));
            data.aoeMaxDamage = XmlUtil.getNumberAttr(xml, "aoeMaxDamage",
                (useDefaults ? defaults.aoeMaxDamage : undefined));
        }

        return data;
    }
}

}
