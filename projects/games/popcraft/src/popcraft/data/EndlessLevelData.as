package popcraft.data {

import com.threerings.util.ArrayUtil;

import popcraft.*;
import popcraft.util.XmlReader;

public class EndlessLevelData
{
    public var humanPlayerNames :Array = [];
    public var mapSequence :Array = []; // array of EndlessMapDatas

    public function getWorkshopMaxHealth (mapIndex :int) :Number
    {
        var mapData :EndlessMapData = getMapData(mapIndex);
        var gameData :GameData = (mapData.gameDataOverride != null ?
            mapData.gameDataOverride : ClientCtx.defaultGameData);
        return UnitData(gameData.units[Constants.UNIT_TYPE_WORKSHOP]).maxHealth;
    }

    public function getMapData (mapIndex :int) :EndlessMapData
    {
        return mapSequence[mapIndex % mapSequence.length];
    }

    public function getMapCycleNumber (mapIndex :int) :int
    {
        return Math.floor(mapIndex / mapSequence.length);
    }

    public function getNumberedMapDisplayName (mapIndex :int) :String
    {
        return String(mapIndex + 1) + ". " + getMapData(mapIndex).displayName
    }

    public static function fromXml (xml :XML) :EndlessLevelData
    {
        var data :EndlessLevelData = new EndlessLevelData();

        for each (var nameXml :XML in xml.HumanPlayers.Player) {
            data.humanPlayerNames.push(XmlReader.getStringAttr(nameXml, "name"));
        }

        for each (var mapSequenceXml :XML in xml.MapSequence.Map) {
            data.mapSequence.push(EndlessMapData.fromXml(mapSequenceXml));
        }

        return data;
    }
}

}
