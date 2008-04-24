package popcraft.data {

import com.whirled.contrib.simplegame.resource.XmlResourceLoader;

public class GameDataResourceLoader extends XmlResourceLoader
{
    public function GameDataResourceLoader (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams, objectGenerator);
    }

    public function get gameData () :GameData
    {
        return super.generatedObject as GameData;
    }

    protected static function objectGenerator (xml :XML) :GameData
    {
        return GameData.fromXml(xml.GameData[0]);
    }

}

}
