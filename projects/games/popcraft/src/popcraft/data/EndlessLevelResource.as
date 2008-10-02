package popcraft.data {

import com.whirled.contrib.simplegame.resource.XmlResource;

public class EndlessLevelResource extends XmlResource
{
    public function EndlessLevelResource (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams, objectGenerator);
    }

    public function get levelData () :EndlessLevelData
    {
        return super.generatedObject as EndlessLevelData;
    }

    protected static function objectGenerator (xml :XML) :EndlessLevelData
    {
        return EndlessLevelData.fromXml(xml.EndlessLevel[0]);
    }

}

}
