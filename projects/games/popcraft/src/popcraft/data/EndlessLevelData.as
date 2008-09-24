package popcraft.data {

public class EndlessLevelData
{
    public var gameDataOverride :GameData;
    public var mapSequence :Array = []; // array of EndlessMapDatas

    public static function fromXml (xml :XML) :EndlessLevelData
    {
        var level :EndlessLevelData = new EndlessLevelData();

        // does the level override game data?
        var gameDataOverrideNode :XML = xml.GameDataOverride[0];
        if (null != gameDataOverrideNode) {
            level.gameDataOverride = GameData.fromXml(gameDataOverrideNode, AppContext.defaultGameData.clone());
        }

        for each (var mapSequenceData :XML in xml.MapSequence.Map) {
            level.mapSequence.push(EndlessMapData.fromXml(mapSequenceData));
        }

        return level;
    }
}

}
