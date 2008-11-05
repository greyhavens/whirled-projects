package popcraft.data {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.util.XmlReader;

public class DataUtil
{
    public static function parseVector2 (xml :XML) :Vector2
    {
        var vec :Vector2 = new Vector2();
        vec.x = XmlReader.getNumberAttr(xml, "x");
        vec.y = XmlReader.getNumberAttr(xml, "y");
        return vec;
    }

    public static function parseCreatureTypes (xml :XML) :Array
    {
        return parseTypes(xml, "Unit", Constants.PLAYER_CREATURE_UNIT_NAMES);
    }

    public static function parseCastableSpellTypes (xml :XML) :Array
    {
        return parseTypes(xml, "Spell", Constants.CASTABLE_SPELL_NAMES);
    }

    protected static function parseTypes (xml :XML, xmlNodeName :String, typeNames :Array) :Array
    {
        var types :Array = [];

        if (XmlReader.getBooleanAttr(xml, "all", false)) {
            for (var type :int = 0; type < typeNames.length; ++type) {
                types.push(type);
            }

        } else {
            for each (var unitData :XML in xml.elements(xmlNodeName)) {
                types.push(XmlReader.getEnumAttr(unitData, "type", typeNames));
            }
        }

        return types;
    }
}

}
