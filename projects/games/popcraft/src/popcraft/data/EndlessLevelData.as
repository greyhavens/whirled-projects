package popcraft.data {

import popcraft.*;
import popcraft.util.XmlReader;

public class EndlessLevelData
{
    public var maxMultiplier :int;
    public var multiplierOverflowScoreValue :int;
    public var multiplierDamageSoak :int;

    public var pointsPerResource :int;

    public var gameDataOverride :GameData;

    public var mapSequence :Array = []; // array of EndlessMapDatas

    public static function fromXml (xml :XML) :EndlessLevelData
    {
        var level :EndlessLevelData = new EndlessLevelData();

        // does the level override game data?
        var gameDataOverrideNode :XML = xml.GameDataOverride[0];
        if (null != gameDataOverrideNode) {
            level.gameDataOverride = GameData.fromXml(gameDataOverrideNode,
                AppContext.defaultGameData.clone());
        }

        level.maxMultiplier = XmlReader.getUintAttr(xml, "maxMultiplier");
        level.multiplierOverflowScoreValue = XmlReader.getIntAttr(xml, "multiplierOverflowScoreValue");
        level.multiplierDamageSoak = XmlReader.getUintAttr(xml, "multiplierDamageSoak");

        level.pointsPerResource = XmlReader.getIntAttr(xml, "pointsPerResource");

        for each (var mapSequenceData :XML in xml.MapSequence.Map) {
            level.mapSequence.push(EndlessMapData.fromXml(mapSequenceData));
        }

        return level;
    }
}

}
