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

    public var multiplierDropLoc :Vector2 = new Vector2();

    public var humans :HashMap = new HashMap(); // Map<PlayerName, EndlessHumanPlayerData>
    public var computers :Array = []; // array of EndlessComputerPlayerDatas

    public static function fromXml (xml :XML) :EndlessMapData
    {
        var mapData :EndlessMapData = new EndlessMapData();

        mapData.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        mapData.displayName = XmlReader.getStringAttr(xml, "displayName");
        mapData.isSavePoint = XmlReader.getBooleanAttr(xml, "isSavePoint");

        for each (var humanXml :XML in xml.HumanPlayers.HumanPlayer) {
            var playerName :String = XmlReader.getStringAttr(humanXml, "playerName");
            var humanPlayerData :EndlessHumanPlayerData = EndlessHumanPlayerData.fromXml(humanXml);
            mapData.humans.put(playerName, humanPlayerData);
        }

        var multiplierDropXml :XML = XmlReader.getSingleChild(xml, "MultiplierDropLocation");
        mapData.multiplierDropLoc = DataUtil.parseVector2(multiplierDropXml);

        for each (var computerXml :XML in xml.Computer) {
            mapData.computers.push(EndlessComputerPlayerData.fromXml(computerXml));
        }

        return mapData;
    }
}

}
