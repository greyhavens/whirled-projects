package popcraft.data {

import com.threerings.flash.Vector2;
import com.threerings.util.HashMap;

import popcraft.*;
import popcraft.util.XmlReader;

public class EndlessMapData
{
    public var mapSettings :MapSettingsData;

    public var displayName :String;
    public var isSavePoint :Boolean;

    public var humanBaseLocs :HashMap = new HashMap(); // Map<PlayerName, BaseLocation>
    public var multiplierDropLoc :Vector2 = new Vector2();

    public var computers :Array = []; // array of EndlessComputerPlayerDatas
    public var availableUnits :Array = [];
    public var availableSpells :Array = [];

    public static function fromXml (xml :XML) :EndlessMapData
    {
        var mapData :EndlessMapData = new EndlessMapData();

        mapData.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        mapData.displayName = XmlReader.getStringAttr(xml, "displayName");
        mapData.isSavePoint = XmlReader.getBooleanAttr(xml, "isSavePoint");

        for each (var baseLocXml :XML in xml.HumanBaseLocations.BaseLocation) {
            var playerName :String = XmlReader.getStringAttr(baseLocXml, "playerName");
            var baseLoc :BaseLocationData = BaseLocationData.fromXml(baseLocXml);
            mapData.humanBaseLocs.put(playerName, baseLoc);
        }

        var multiplierDropXml :XML = XmlReader.getSingleChild(xml, "MultiplierDropLocation");
        mapData.multiplierDropLoc = DataUtils.parseVector2(multiplierDropXml);

        for each (var computerXml :XML in xml.Computer) {
            mapData.computers.push(EndlessComputerPlayerData.fromXml(computerXml));
        }

        // parse the available units and spells
        mapData.availableUnits = DataUtils.parseCreatureTypes(xml.AvailableUnits[0]);
        mapData.availableSpells = DataUtils.parseCastableSpellTypes(xml.AvailableSpells[0]);

        return mapData;
    }
}

}
