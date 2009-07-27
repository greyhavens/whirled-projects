package popcraft.data {

import com.threerings.geom.Vector2;
import com.whirled.contrib.XmlReader;

public class BaseLocationData
{
    public var loc :Vector2 = new Vector2();
    public var team :int;

    public static function fromXml (xml :XML) :BaseLocationData
    {
        var data :BaseLocationData = new BaseLocationData();
        data.loc.x = XmlReader.getNumberAttr(xml, "x");
        data.loc.y = XmlReader.getNumberAttr(xml, "y");
        data.team = XmlReader.getIntAttr(xml, "team");

        return data;
    }

}

}
