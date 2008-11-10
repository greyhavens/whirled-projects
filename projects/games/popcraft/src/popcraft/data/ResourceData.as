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

    public static function fromXml (xml :XML, defaults :ResourceData = null) :ResourceData
    {
        var useDefaults :Boolean = (null != defaults);
        var data :ResourceData = (useDefaults ? defaults : new ResourceData());

        data.displayName = XmlReader.getStringAttr(xml, "displayName",
            (useDefaults ? defaults.displayName : undefined));
        data.color = XmlReader.getUintAttr(xml, "color",
            (useDefaults ? defaults.color : undefined));
        data.hiliteColor = XmlReader.getUintAttr(xml, "hiliteColor",
            (useDefaults ? defaults.hiliteColor : undefined));
        data.rarity = XmlReader.getNumberAttr(xml, "rarity",
            (useDefaults ? defaults.rarity : undefined));

        return data;
    }
}

}
