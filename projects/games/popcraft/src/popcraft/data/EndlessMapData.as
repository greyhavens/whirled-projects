package popcraft.data {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.util.XmlReader;

public class EndlessMapData
{
    public var mapSettings :MapSettingsData;

    public var humanBaseLocs :Array = []; // array of BaseLocationDatas
    public var multiplierDropLoc :Vector2 = new Vector2();

    public var computerGroups :Array = []; // array of arrays of EndlessComputerPlayerDatas
    public var availableUnits :Array = [];
    public var availableSpells :Array = [];
    public var repeats :Boolean; // does this MapData repeat when the map sequence cycles?

    public static function fromXml (xml :XML) :EndlessMapData
    {
        var mapData :EndlessMapData = new EndlessMapData();

        mapData.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        for each (var baseLocXml :XML in xml.HumanBaseLocations.BaseLocation) {
            mapData.humanBaseLocs.push(BaseLocationData.fromXml(baseLocXml));
        }

        mapData.multiplierDropLoc =
            DataUtils.parseVector2(XmlReader.getSingleChild(xml, "MultiplierDropLocation"));

        for each (var computerGroupXml :XML in xml.ComputerGroups.Group) {
            var group :Array = [];
            for each (var computerXml :XML in computerGroupXml.Computer) {
                group.push(EndlessComputerPlayerData.fromXml(computerXml));
            }

            mapData.computerGroups.push(group);
        }

        // parse the available units and spells
        mapData.availableUnits = DataUtils.parseCreatureTypes(xml.AvailableUnits[0]);
        mapData.availableSpells = DataUtils.parseCastableSpellTypes(xml.AvailableSpells[0]);

        mapData.repeats = XmlReader.getBooleanAttr(xml, "repeats");

        return mapData;
    }
}

}
