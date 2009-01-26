package popcraft.data {

import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.DisplayObject;

import popcraft.*;
import popcraft.util.XmlReader;

public class PlayerDisplayData
{
    public var playerName :String;
    public var displayName :String;
    public var headshotName :String;
    public var color :uint;
    public var excludeFromMpBattle :Boolean;

    public function get headshot () :DisplayObject
    {
        return ClientCtx.instantiateBitmap(headshotName);
    }

    public function clone () :PlayerDisplayData
    {
        var theClone :PlayerDisplayData = new PlayerDisplayData();
        theClone.playerName = playerName;
        theClone.displayName = displayName;
        theClone.headshotName = headshotName;
        theClone.excludeFromMpBattle = excludeFromMpBattle;
        theClone.color = color;

        return theClone;
    }

    public static function fromXml (xml :XML, defaults :PlayerDisplayData = null)
        :PlayerDisplayData
    {
        var useDefaults :Boolean = (defaults != null);
        var data :PlayerDisplayData = (useDefaults ? defaults : new PlayerDisplayData());

        data.playerName = XmlReader.getStringAttr(xml, "name");
        data.displayName = XmlReader.getStringAttr(xml, "displayName",
            (useDefaults ? defaults.displayName : undefined));
        data.headshotName = XmlReader.getStringAttr(xml, "headshotName",
            (useDefaults ? defaults.headshotName : undefined));
        data.color = XmlReader.getUintAttr(xml, "color",
            (useDefaults ? defaults.color : undefined));
        data.excludeFromMpBattle = XmlReader.getBooleanAttr(xml, "excludeFromMpBattle",
            (useDefaults ? defaults.excludeFromMpBattle : false));

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
