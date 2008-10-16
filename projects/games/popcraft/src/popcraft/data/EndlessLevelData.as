package popcraft.data {

import com.threerings.util.ArrayUtil;

import popcraft.*;
import popcraft.util.XmlReader;

public class EndlessLevelData
{
    public var humanPlayerNames :Array = [];

    public var maxMultiplier :int;
    public var multiplierDamageSoak :Number;

    public var pointsPerExtraMultiplier :int;
    public var pointsPerResource :int;
    public var pointsPerOpponentKill :int;
    public var pointsPerCreatureKill :Array; // score for each unit type

    public var gameDataOverride :GameData;

    public var mapSequence :Array = []; // array of EndlessMapDatas

    public function getMapData (mapIndex :int) :EndlessMapData
    {
        return mapSequence[mapIndex % mapSequence.length];
    }

    public function getMapCycleNumber (mapIndex :int) :int
    {
        return Math.floor(mapIndex / mapSequence.length);
    }

    public static function fromXml (xml :XML) :EndlessLevelData
    {
        var level :EndlessLevelData = new EndlessLevelData();

        // does the level override game data?
        var gameDataOverrideNode :XML = xml.GameDataOverride[0];
        if (null != gameDataOverrideNode) {
            level.gameDataOverride = GameData.fromXml(gameDataOverrideNode,
                AppContext.defaultGameData.clone());
        }

        for each (var nameXml :XML in xml.HumanPlayers.Player) {
            level.humanPlayerNames.push(XmlReader.getStringAttr(nameXml, "name"));
        }

        level.maxMultiplier = XmlReader.getUintAttr(xml, "maxMultiplier");
        level.multiplierDamageSoak = XmlReader.getNumberAttr(xml, "multiplierDamageSoak");

        level.pointsPerExtraMultiplier = XmlReader.getIntAttr(xml, "pointsPerExtraMultiplier");
        level.pointsPerResource = XmlReader.getIntAttr(xml, "pointsPerResource");
        level.pointsPerOpponentKill = XmlReader.getIntAttr(xml, "pointsPerOpponentKill");

        level.pointsPerCreatureKill = ArrayUtil.create(Constants.CREATURE_UNIT_NAMES.length, 0);
        for each (var unitXml :XML in xml.PointsPerCreatureKill.Unit) {
            var unitType :int = XmlReader.getEnumAttr(unitXml, "type", Constants.CREATURE_UNIT_NAMES);
            var points :int = XmlReader.getIntAttr(unitXml, "points");
            level.pointsPerCreatureKill[unitType] = points;
        }

        for each (var mapSequenceXml :XML in xml.MapSequence.Map) {
            level.mapSequence.push(EndlessMapData.fromXml(mapSequenceXml));
        }

        return level;
    }
}

}
