package popcraft.battle {

import popcraft.*;
import popcraft.util.*;

public class UnitSpellData
{
    public var type :uint;
    public var displayName :String;
    public var expireTime :Number = 0;

    public var speedScaleOffset :Number = 0;
    public var damageScaleOffset :Number = 0;

    public function combine (spell :UnitSpellData) :void
    {
        speedScaleOffset += spell.speedScaleOffset;
        damageScaleOffset += spell.damageScaleOffset;
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
