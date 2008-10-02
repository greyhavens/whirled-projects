package popcraft.data {

import com.threerings.flash.Vector2;

import popcraft.util.XmlReader;

public class BaseLocationData
{
    public var loc :Vector2 = new Vector2();
    public var team :int;

    public static function fromXml (xml :XML) :BaseLocationData
    {
        var data :BaseLocationData = new BaseLocationData();
        data.loc.x = XmlReader.getAttributeAsNumber(xml, "x");
        data.loc.y = XmlReader.getAttributeAsNumber(xml, "y");
        data.team = XmlReader.getAttributeAsInt(xml, "team");

        return data;
    }

}

}
