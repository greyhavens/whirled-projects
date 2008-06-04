package popcraft.data {

import popcraft.*;
import popcraft.util.*;

public class SpellData
{
    public var type :uint;
    public var displayName :String;
    public var description :String;

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
        theClone.description = description;

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :SpellData = null) :SpellData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var spell :SpellData = (useDefaults ? inheritFrom : new SpellData());

        spell.type = XmlReader.getAttributeAsEnum(xml, "type", Constants.SPELL_NAMES);
        spell.displayName = XmlReader.getAttributeAsString(xml, "displayName", (useDefaults ? inheritFrom.displayName : undefined));
        spell.description = XmlReader.getAttributeAsString(xml, "description", (useDefaults ? inheritFrom.description : undefined));

        return spell;
    }

}

}
