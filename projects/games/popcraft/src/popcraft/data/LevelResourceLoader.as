package popcraft.data {

import com.whirled.contrib.simplegame.resource.XmlResource;

public class LevelResourceLoader extends XmlResource
{
    public function LevelResourceLoader (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams, objectGenerator);
    }

    public function get levelData () :LevelData
    {
        return super.generatedObject as LevelData;
    }

    protected static function objectGenerator (xml :XML) :LevelData
    {
        return LevelData.fromXml(xml.Level[0]);
    }

}

}
