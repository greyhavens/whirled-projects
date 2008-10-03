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

        resource.displayName = XmlReader.getStringAttr(xml, "displayName",
            (useDefaults ? inheritFrom.displayName : undefined));
        resource.color = XmlReader.getUintAttr(xml, "color",
            (useDefaults ? inheritFrom.color : undefined));
        resource.hiliteColor = XmlReader.getUintAttr(xml, "hiliteColor",
            (useDefaults ? inheritFrom.hiliteColor : undefined));
        resource.rarity = XmlReader.getNumberAttr(xml, "rarity",
            (useDefaults ? inheritFrom.rarity : undefined));

        return resource;
    }
}

}
