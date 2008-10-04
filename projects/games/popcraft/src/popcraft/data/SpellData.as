package popcraft.data {

import popcraft.*;
import popcraft.util.*;

public class SpellData
{
    public var type :int;
    public var displayName :String;
    public var introText :String;

    public function get name () :String
    {
        return Constants.SPELL_NAMES[type];
    }

    public function get iconName () :String
    {
        // TODO - change this when we get art
        if (type == Constants.SPELL_TYPE_MULTIPLIER) {
            return "infusion_rigormortis";
        }

        return "infusion_" + this.name;
    }

    public function clone (theClone :SpellData = null) :SpellData
    {
        if (null == theClone) {
            theClone = new SpellData();
        }

        theClone.type = type;
        theClone.displayName = displayName;
        theClone.introText = introText;

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :SpellData = null) :SpellData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var spell :SpellData = (useDefaults ? inheritFrom : new SpellData());

        spell.type = XmlReader.getEnumAttr(xml, "type", Constants.SPELL_NAMES);
        spell.displayName = XmlReader.getStringAttr(xml, "displayName",
            (useDefaults ? inheritFrom.displayName : undefined));
        spell.introText = XmlReader.getStringAttr(xml, "introText",
            (useDefaults ? inheritFrom.introText : undefined));

        return spell;
    }

}

}
