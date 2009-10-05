package popcraft.data {

import com.threerings.flashbang.resource.XmlResource;

public class LevelResource extends XmlResource
{
    public function LevelResource (resourceName :String, loadParams :Object)
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
