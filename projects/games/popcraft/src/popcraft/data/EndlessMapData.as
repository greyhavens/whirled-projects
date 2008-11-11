package popcraft.data {

import com.threerings.flash.Vector2;
import com.threerings.util.HashMap;

import popcraft.*;
import popcraft.util.XmlReader;

public class EndlessMapData
{
    public var gameDataOverride :GameData;
    public var mapSettings :MapSettingsData;

    public var displayName :String;
    public var isSavePoint :Boolean;

    public var multiplierDropLoc :Vector2 = new Vector2();

    public var humans :HashMap = new HashMap(); // Map<PlayerName, EndlessHumanPlayerData>
    public var computers :Array = []; // array of EndlessComputerPlayerDatas

    public static function fromXml (xml :XML) :EndlessMapData
    {
        var data :EndlessMapData = new EndlessMapData();

        // does the level override game data?
        var gameDataOverrideNode :XML = xml.GameDataOverride[0];
        if (null != gameDataOverrideNode) {
            data.gameDataOverride = GameData.fromXml(gameDataOverrideNode,
                                                        AppContext.defaultGameData.clone());
        }

        data.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        data.displayName = XmlReader.getStringAttr(xml, "displayName");
        data.isSavePoint = XmlReader.getBooleanAttr(xml, "isSavePoint");

        for each (var humanXml :XML in xml.HumanPlayers.HumanPlayer) {
            var playerName :String = XmlReader.getStringAttr(humanXml, "playerName");
            var humanPlayerData :EndlessHumanPlayerData = EndlessHumanPlayerData.fromXml(humanXml);
            data.humans.put(playerName, humanPlayerData);
        }

        var multiplierDropXml :XML = XmlReader.getSingleChild(xml, "MultiplierDropLocation");
        data.multiplierDropLoc = DataUtil.parseVector2(multiplierDropXml);

        for each (var computerXml :XML in xml.Computer) {
            data.computers.push(EndlessComputerPlayerData.fromXml(computerXml));
        }

        return data;
    }
}

}
