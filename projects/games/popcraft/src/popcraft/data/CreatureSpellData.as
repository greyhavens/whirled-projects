package popcraft.data {

import com.threerings.util.XmlUtil;

import popcraft.*;
import popcraft.util.*;

public class CreatureSpellData extends SpellData
{
    public var expireTime :Number = 0;
    public var speedScaleOffset :Number = 0;
    public var damageScaleOffset :Number = 0;

    public function combine (spell :CreatureSpellData) :void
    {
        speedScaleOffset += spell.speedScaleOffset;
        damageScaleOffset += spell.damageScaleOffset;
    }

    override public function clone (theClone :SpellData = null) :SpellData
    {
        if (null == theClone) {
            theClone = new CreatureSpellData();
        }

        super.clone(theClone);

        var creatureClone :CreatureSpellData = theClone as CreatureSpellData;

        creatureClone.expireTime = expireTime;
        creatureClone.speedScaleOffset = speedScaleOffset;
        creatureClone.damageScaleOffset = damageScaleOffset;

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :CreatureSpellData = null)
        :CreatureSpellData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var spell :CreatureSpellData = (useDefaults ? inheritFrom : new CreatureSpellData());

        SpellData.fromXml(xml, spell);

        spell.expireTime = XmlUtil.getNumberAttr(xml, "expireTime",
            (useDefaults ? inheritFrom.expireTime : undefined));
        spell.speedScaleOffset = XmlUtil.getNumberAttr(xml, "speedScaleOffset",
            (useDefaults ? inheritFrom.speedScaleOffset : 0));
        spell.damageScaleOffset = XmlUtil.getNumberAttr(xml, "damageScaleOffset",
            (useDefaults ? inheritFrom.damageScaleOffset : 0));

        return spell;
    }
}

}
