package popcraft.data {

import popcraft.util.*;

public class ResourceData
{
    public var displayName :String = "";
    public var color :uint;
    public var rarity :Number = 0;

    public function ResourceData (displayName :String = "", color :uint = 0, rarity :Number = 1)
    {
        this.displayName = displayName;
        this.color = color;
        this.rarity = rarity;
    }

    public function clone () :ResourceData
    {
        var theClone :ResourceData = new ResourceData();
        theClone.displayName = displayName;
        theClone.color = color;
        theClone.rarity = rarity;
        return theClone;
    }

    public static function fromXml (xml :XML) :ResourceData
    {
        var resource :ResourceData = new ResourceData();

        resource.displayName = XmlReader.getAttributeAsString(xml, "displayName");
        resource.color = XmlReader.getAttributeAsUint(xml, "color");
        resource.rarity = XmlReader.getAttributeAsNumber(xml, "rarity");

        return resource;
    }
}

}
