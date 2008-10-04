package popcraft.data {

import popcraft.*;
import popcraft.util.XmlReader;

public class DataUtils
{
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
