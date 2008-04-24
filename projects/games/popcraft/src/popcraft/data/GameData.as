package popcraft.data {

import popcraft.*;
import popcraft.util.*;

public class GameData
{
    public var resourceTypes :Array = [];
    public var units :Array = [];
    public var spells :Array = [];

    public static function fromXml (xml :XML) :GameData
    {
        var gameData :GameData = new GameData();

        // init the resource data
        for (var i :int = 0; i < Constants.RESOURCE_NAMES.length; ++i) {
            gameData.resourceTypes.push(null);
        }

        for each (var resourceNode :XML in xml.Resources.Resource) {
            var type :uint = XmlReader.getAttributeAsEnum(resourceNode, "type", Constants.RESOURCE_NAMES);
            gameData.resourceTypes[type] = ResourceData.fromXml(resourceNode);
        }

        // init the unit data
        for (i = 0; i < Constants.UNIT_NAMES.length; ++i) {
            gameData.units.push(null);
        }

        for each (var unitNode :XML in xml.Units.Unit) {
            type = XmlReader.getAttributeAsEnum(unitNode, "type", Constants.UNIT_NAMES);
            gameData.units[type] = UnitData.fromXml(unitNode);
        }

        // init the spell data
        for (i = 0; i < Constants.SPELL_NAMES.length; ++i) {
            gameData.spells.push(null);
        }

        for each (var spellNode :XML in xml.Spells.Spell) {
            type = XmlReader.getAttributeAsEnum(spellNode, "type", Constants.SPELL_NAMES);
            gameData.spells[type] = UnitSpellData.fromXml(spellNode);
        }
    }
}

}
