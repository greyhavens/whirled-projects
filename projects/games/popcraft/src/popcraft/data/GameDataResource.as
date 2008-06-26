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
        return LoadedData(this.generatedObject).gameData;
    }

    public function get levelProgression () :LevelProgressionData
    {
        return LoadedData(this.generatedObject).levelProgression;
    }

    public function get multiplayerSettings () :Array
    {
        return LoadedData(this.generatedObject).multiplayerSettings;
    }

    public function get introOutroData () :IntroOutroData
    {
        return LoadedData(this.generatedObject).introOutroData;
    }

    protected static function objectGenerator (xml :XML) :LoadedData
    {
        var loadedData :LoadedData = new LoadedData();
        loadedData.gameData = GameData.fromXml(xml.GameData[0]);
        loadedData.levelProgression = LevelProgressionData.fromXml(xml.LevelProgression[0]);

        for each (var msXml :XML in xml.Multiplayer.MultiplayerSettings) {
            loadedData.multiplayerSettings.push(MultiplayerSettingsData.fromXml(msXml));
        }

        loadedData.introOutroData = IntroOutroData.fromXml(xml.IntroOutro[0]);

        return loadedData;
    }
}

}

import popcraft.data.*;

class LoadedData
{
    public var gameData :GameData;
    public var levelProgression :LevelProgressionData;
    public var multiplayerSettings :Array = [];
    public var introOutroData :IntroOutroData;
}
