package popcraft.data {

import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.DisplayObject;

import popcraft.util.XmlReader;

public class PlayerDisplayData
{
    public var playerName :String;
    public var displayName :String;
    public var headshotName :String;
    public var color :uint;

    public function get headshot () :DisplayObject
    {
        return ImageResource.instantiateBitmap(headshotName);
    }

    public function clone () :PlayerDisplayData
    {
        var theClone :PlayerDisplayData = new PlayerDisplayData();
        theClone.playerName = playerName;
        theClone.displayName = displayName;
        theClone.headshotName = headshotName;
        theClone.color = color;

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :PlayerDisplayData = null)
        :PlayerDisplayData
    {
        var data :PlayerDisplayData = new PlayerDisplayData();

        data.playerName = XmlReader.getStringAttr(xml, "name");
        data.displayName = XmlReader.getStringAttr(xml, "displayName",
            (null != inheritFrom ? inheritFrom.displayName : undefined));
        data.headshotName = XmlReader.getStringAttr(xml, "headshotName",
            (null != inheritFrom ? inheritFrom.headshotName : undefined));
        data.color = XmlReader.getUintAttr(xml, "color",
            (null != inheritFrom ? inheritFrom.color : undefined));

        return data;
    }

    public static function get unknown () :PlayerDisplayData
    {
        if (_unknown == null) {
            _unknown = new PlayerDisplayData();
            _unknown.playerName = "unknown";
            _unknown.displayName = "???";
            _unknown.headshotName = "???";
            _unknown.color = 0;
        }

        return _unknown;
    }

    protected static var _unknown :PlayerDisplayData;
}

}
