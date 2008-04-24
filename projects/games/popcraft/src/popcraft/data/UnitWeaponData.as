package popcraft.data {

import com.whirled.contrib.simplegame.util.*;

import popcraft.*;
import popcraft.util.*;

public class UnitWeaponData
{
    // General weapon options
    public var damageType :uint;
    public var cooldown :Number = 0;
    public var maxAttackDistance :Number = 0;
    public var damageRange :NumRange;

    // Ranged weapon options
    public var isRanged :Boolean;
    public var missileSpeed :Number = 0; // pixels/second

    // AOE weapon options
    public var isAOE :Boolean;
    public var aoeRadius :Number = 0;
    public var aoeAnimationName :String;
    public var aoeDamageFriendlies :Boolean;

    public function get aoeRadiusSquared () :Number
    {
        return aoeRadius * aoeRadius;
    }

    public static function fromXml (xml :XML) :UnitWeaponData
        // throws XmlReadError
    {
        var weapon :UnitWeaponData = new UnitWeaponData();

        weapon.damageType = XmlReader.getAttributeAsEnum(xml, "damageType", Constants.DAMAGE_TYPE_NAMES);
        weapon.cooldown = XmlReader.getAttributeAsNumber(xml, "cooldown");
        weapon.maxAttackDistance = XmlReader.getAttributeAsNumber(xml, "maxAttackDistance");

        var damageMin :Number = XmlReader.getAttributeAsNumber(xml, "damageMin");
        var damageMax :Number = XmlReader.getAttributeAsNumber(xml, "damageMax");
        weapon.damageRange = new NumRange(damageMin, damageMax, Rand.STREAM_GAME);

        // ranged weapons
        weapon.isRanged = XmlReader.getAttributeAsBoolean(xml, "isRanged", false);
        if (weapon.isRanged) {
            weapon.missileSpeed = XmlReader.getAttributeAsNumber(xml, "missileSpeed");
        }

        // AOE weapons
        weapon.isAOE = XmlReader.getAttributeAsBoolean(xml, "isAOE", false);
        if (weapon.isAOE) {
            weapon.aoeRadius = XmlReader.getAttributeAsNumber(xml, "aoeRadius");
            weapon.aoeAnimationName = XmlReader.getAttributeAsString(xml, "aoeAnimationName");
            weapon.aoeDamageFriendlies = XmlReader.getAttributeAsBoolean(xml, "aoeDamageFriendlies");
        }

        return weapon;
    }
}

}
