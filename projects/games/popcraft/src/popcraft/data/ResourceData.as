package popcraft.data {

import com.threerings.util.XmlUtil;

import popcraft.util.*;

public class ResourceData
{
    public var displayName :String = "";
    public var color :uint;
    public var hiliteColor :uint;
    public var frequency :Number = 0;

    public function clone () :ResourceData
    {
        var theClone :ResourceData = new ResourceData();
        theClone.displayName = displayName;
        theClone.color = color;
        theClone.hiliteColor = hiliteColor;
        theClone.frequency = frequency;
        return theClone;
    }

    public static function fromXml (xml :XML, defaults :ResourceData = null) :ResourceData
    {
        var useDefaults :Boolean = (null != defaults);
        var data :ResourceData = (useDefaults ? defaults : new ResourceData());

        data.displayName = XmlUtil.getStringAttr(xml, "displayName",
            (useDefaults ? defaults.displayName : undefined));
        data.color = XmlUtil.getUintAttr(xml, "color",
            (useDefaults ? defaults.color : undefined));
        data.hiliteColor = XmlUtil.getUintAttr(xml, "hiliteColor",
            (useDefaults ? defaults.hiliteColor : undefined));
        data.frequency = XmlUtil.getNumberAttr(xml, "frequency",
            (useDefaults ? defaults.frequency : undefined));

        return data;
    }
}

}
