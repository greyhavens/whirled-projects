package redrover.data {

import redrover.util.XmlReader;

public class LevelData
{
    public var terrain :Array = [];

    public static function fromXml (xml :XML) :LevelData
    {
        var data :LevelData = new LevelData();
        var terrStr :String = xml.Terrain;
        return data;
    }
}

}
