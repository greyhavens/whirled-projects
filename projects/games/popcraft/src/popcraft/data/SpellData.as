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

        spell.type = XmlReader.getAttributeAsEnum(xml, "type", Constants.SPELL_NAMES);
        spell.displayName = XmlReader.getAttributeAsString(xml, "displayName",
            (useDefaults ? inheritFrom.displayName : undefined));
        spell.introText = XmlReader.getAttributeAsString(xml, "introText",
            (useDefaults ? inheritFrom.introText : undefined));

        return spell;
    }

}

}
