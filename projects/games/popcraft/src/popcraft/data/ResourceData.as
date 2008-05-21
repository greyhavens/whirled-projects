package popcraft.data {

import popcraft.util.*;

public class ResourceData
{
    public var displayName :String = "";
    public var color :uint;
    public var hiliteColor :uint;
    public var rarity :Number = 0;

    public function clone () :ResourceData
    {
        var theClone :ResourceData = new ResourceData();
        theClone.displayName = displayName;
        theClone.color = color;
        theClone.hiliteColor = hiliteColor;
        theClone.rarity = rarity;
        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :ResourceData = null) :ResourceData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var resource :ResourceData = (useDefaults ? inheritFrom : new ResourceData());

        resource.displayName = XmlReader.getAttributeAsString(xml, "displayName", (useDefaults ? inheritFrom.displayName : undefined));
        resource.color = XmlReader.getAttributeAsUint(xml, "color", (useDefaults ? inheritFrom.color : undefined));
        resource.hiliteColor = XmlReader.getAttributeAsUint(xml, "hiliteColor", (useDefaults ? inheritFrom.hiliteColor : undefined));
        resource.rarity = XmlReader.getAttributeAsNumber(xml, "rarity", (useDefaults ? inheritFrom.rarity : undefined));

        return resource;
    }
}

}
