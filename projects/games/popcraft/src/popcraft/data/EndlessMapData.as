package popcraft.data {

public class EndlessMapData
{
    public var mapSettings :MapSettingsData;

    public var computerGroups :Array = []; // array of arrays of ComputerPlayerDatas
    public var availableUnits :Array = [];
    public var availableSpells :Array = [];

    public static function fromXml (xml :XML) :EndlessMapData
    {
        var mapData :EndlessMapData = new EndlessMapData();

        mapData.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        for each (var computerGroupNode :XML in xml.ComputerGroups.Group) {
            var group :Array = [];
            for each (var computerNode :XML in computerGroupNode.Computer) {
                group.push(ComputerPlayerData.fromXml(computerNode));
            }

            mapData.computerGroups.push(group);
        }

        // parse the available units
        for each (var unitData :XML in xml.AvailableUnits.Unit) {
            level.availableUnits.push(XmlReader.getAttributeAsEnum(unitData, "type",
                Constants.PLAYER_CREATURE_UNIT_NAMES));
        }

        // parse available spells
        for each (var spellData :XML in xml.AvailableSpells.Spell) {
            level.availableSpells.push(XmlReader.getAttributeAsEnum(spellData, "type",
                Constants.SPELL_NAMES));
        }
    }
}

}
