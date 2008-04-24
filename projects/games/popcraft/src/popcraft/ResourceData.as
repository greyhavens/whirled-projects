package popcraft {

import popcraft.util.*;

public class ResourceData
{
    public var name :String;
    public var color :uint;
    public var rarity :Number;

    public function ResourceData (name :String = "", color :uint = 0, rarity :Number = 1)
    {
        this.name = name;
        this.color = color;
        this.rarity = rarity;
    }

    public static function fromXml (xml :XML) :ResourceData
    {
        var resource :ResourceData = new ResourceData();

        resource.name = XmlReader.getAttributeAsString(xml, "name");
        resource.color = XmlReader.getAttributeAsUint(xml, "color");
        resource.rarity = XmlReader.getAttributeAsNumber(xml, "rarity");

        return resource;
    }
}

}
