package popcraft.data {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.util.XmlReader;

public class MultiplayerSettingsData
{
    public var arrangeType :int;
    public var smallerTeamHandicap :Number;
    public var bgName :String;
    public var mapSizeX :Number;
    public var mapSizeY :Number;
    public var scaleSprites :Boolean;
    public var baseLocs :Array = [];

    public function clone () :MultiplayerSettingsData
    {
        var theClone :MultiplayerSettingsData = new MultiplayerSettingsData();

        theClone.arrangeType = arrangeType;
        theClone.smallerTeamHandicap = smallerTeamHandicap;
        theClone.bgName = bgName;
        theClone.mapSizeX = mapSizeX;
        theClone.mapSizeY = mapSizeY;
        theClone.scaleSprites = scaleSprites;

        for each (var baseLoc :Vector2 in baseLocs) {
            theClone.baseLocs.push(baseLoc.clone());
        }

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :MultiplayerSettingsData = null) :MultiplayerSettingsData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var data :MultiplayerSettingsData = (useDefaults ? inheritFrom : new MultiplayerSettingsData());

        data.arrangeType = XmlReader.getAttributeAsEnum(xml, "arrangeType", Constants.MULTIPLAYER_ARRANGEMENT_NAMES, (useDefaults ? inheritFrom.arrangeType : undefined));
        data.smallerTeamHandicap = XmlReader.getAttributeAsNumber(xml, "smallerTeamHandicap", (useDefaults ? inheritFrom.smallerTeamHandicap : undefined));
        data.bgName = XmlReader.getAttributeAsString(xml, "bgName", (useDefaults ? inheritFrom.bgName : undefined));
        data.mapSizeX = XmlReader.getAttributeAsNumber(xml, "mapSizeX", (useDefaults ? inheritFrom.mapSizeX : undefined));
        data.mapSizeY = XmlReader.getAttributeAsNumber(xml, "mapSizeY", (useDefaults ? inheritFrom.mapSizeY : undefined));
        data.scaleSprites = XmlReader.getAttributeAsBoolean(xml, "scaleSprites", (useDefaults ? inheritFrom.scaleSprites : undefined));

        if (xml.BaseLocation.length > 0) {
            data.baseLocs.length = 0;
        }

        for each (var baseLocXml :XML in xml.BaseLocation) {
            var x :Number = XmlReader.getAttributeAsNumber(baseLocXml, "x");
            var y :Number = XmlReader.getAttributeAsNumber(baseLocXml, "y");
            data.baseLocs.push(new Vector2(x, y));
        }

        return data;
    }
}

}
