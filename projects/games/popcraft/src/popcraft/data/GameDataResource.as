package popcraft.data {

import com.whirled.contrib.simplegame.resource.XmlResource;

public class GameDataResource extends XmlResource
{
    public function GameDataResource (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams, objectGenerator);
    }

    public function get gameData () :GameData
    {
        return LoadedData(super.generatedObject).gameData;
    }

    public function get levelProgression () :LevelProgressionData
    {
        return LoadedData(super.generatedObject).levelProgression;
    }

    protected static function objectGenerator (xml :XML) :LoadedData
    {
        var loadedData :LoadedData = new LoadedData();
        loadedData.gameData = GameData.fromXml(xml.GameData[0]);
        loadedData.levelProgression = LevelProgressionData.fromXml(xml.LevelProgression[0]);

        return loadedData;
    }
}

}

import popcraft.data.*;

class LoadedData
{
    public var gameData :GameData;
    public var levelProgression :LevelProgressionData;
}
