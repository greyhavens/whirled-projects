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

    public static function fromXml (xml :XML, inheritFrom :ResourceData = null) :ResourceData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var resource :ResourceData = (useDefaults ? inheritFrom : new ResourceData());

        resource.displayName = XmlReader.getAttributeAsString(xml, "displayName", (useDefaults ? inheritFrom.displayName : undefined));
        resource.color = XmlReader.getAttributeAsUint(xml, "color", (useDefaults ? inheritFrom.color : undefined));
        resource.rarity = XmlReader.getAttributeAsNumber(xml, "rarity", (useDefaults ? inheritFrom.rarity : undefined));

        return resource;
    }
}

}
