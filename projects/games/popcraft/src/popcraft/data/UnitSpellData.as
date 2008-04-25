package popcraft.data {

import popcraft.*;
import popcraft.util.*;

public class UnitSpellData
{
    public var type :uint;
    public var displayName :String;
    public var expireTime :Number = 0;

    public var speedScaleOffset :Number = 0;
    public var damageScaleOffset :Number = 0;

    public function get name () :String
    {
        return Constants.SPELL_NAMES[type];
    }

    public function combine (spell :UnitSpellData) :void
    {
        speedScaleOffset += spell.speedScaleOffset;
        damageScaleOffset += spell.damageScaleOffset;
    }

    public function clone () :UnitSpellData
    {
        var theClone :UnitSpellData;

        theClone.type = type;
        theClone.displayName = displayName;
        theClone.expireTime = expireTime;

        theClone.speedScaleOffset = speedScaleOffset;
        theClone.damageScaleOffset = damageScaleOffset;

        return theClone;
    }

    public static function fromXml (xml :XML) :UnitSpellData
    {
        var spell :UnitSpellData = new UnitSpellData();

        spell.type = XmlReader.getAttributeAsEnum(xml, "type", Constants.SPELL_NAMES);
        spell.displayName = XmlReader.getAttributeAsString(xml, "displayName");
        spell.expireTime = XmlReader.getAttributeAsNumber(xml, "expireTime");

        spell.speedScaleOffset = XmlReader.getAttributeAsNumber(xml, "speedScaleOffset", 0);
        spell.damageScaleOffset = XmlReader.getAttributeAsNumber(xml, "damageScaleOffset", 0);

        return spell;
    }
}

}
