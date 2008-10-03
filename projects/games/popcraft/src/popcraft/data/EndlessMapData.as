package popcraft.data {

import popcraft.*;
import popcraft.util.XmlReader;

public class EndlessMapData
{
    public var mapSettings :MapSettingsData;

    public var computerGroups :Array = []; // array of arrays of EndlessComputerPlayerDatas
    public var availableUnits :Array = [];
    public var availableSpells :Array = [];
    public var repeats :Boolean; // does this MapData repeat when the map sequence cycles?

    public static function fromXml (xml :XML) :EndlessMapData
    {
        var mapData :EndlessMapData = new EndlessMapData();

        mapData.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        for each (var computerGroupNode :XML in xml.ComputerGroups.Group) {
            var group :Array = [];
            for each (var computerNode :XML in computerGroupNode.Computer) {
                group.push(EndlessComputerPlayerData.fromXml(computerNode));
            }

            mapData.computerGroups.push(group);
        }

        // parse the available units and spells
        mapData.availableUnits = DataUtils.parseCreatureTypes(xml.AvailableUnits[0]);
        mapData.availableSpells = DataUtils.parseSpellTypes(xml.AvailableSpells[0]);

        mapData.repeats = XmlReader.getBooleanAttr(xml, "repeats");

        return mapData;
    }
}

}
