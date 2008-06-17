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
    public var spellDropLoc :Vector2;
    public var baseLocs :Array = [];

    public static function fromXml (xml :XML) :MultiplayerSettingsData
    {
        var data :MultiplayerSettingsData = new MultiplayerSettingsData();

        data.arrangeType = XmlReader.getAttributeAsEnum(xml, "arrangeType", Constants.MULTIPLAYER_ARRANGEMENT_NAMES);
        data.smallerTeamHandicap = XmlReader.getAttributeAsNumber(xml, "smallerTeamHandicap");
        data.bgName = XmlReader.getAttributeAsString(xml, "bgName");
        data.mapSizeX = XmlReader.getAttributeAsNumber(xml, "mapSizeX");
        data.mapSizeY = XmlReader.getAttributeAsNumber(xml, "mapSizeY");
        data.scaleSprites = XmlReader.getAttributeAsBoolean(xml, "scaleSprites");

        var spellDropXml :XML = XmlReader.getSingleChild(xml, "SpellDropLocation", null);
        if (null != spellDropXml) {
            var x :Number = XmlReader.getAttributeAsNumber(spellDropXml, "x");
            var y :Number = XmlReader.getAttributeAsNumber(spellDropXml, "y");
            data.spellDropLoc = new Vector2(x, y);
        }

        for each (var baseLocXml :XML in xml.BaseLocation) {
            x = XmlReader.getAttributeAsNumber(baseLocXml, "x");
            y = XmlReader.getAttributeAsNumber(baseLocXml, "y");
            data.baseLocs.push(new Vector2(x, y));
        }

        return data;
    }
}

}
