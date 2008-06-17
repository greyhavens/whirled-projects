package popcraft.data {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.util.XmlReader;

public class MapSettingsData
{
    public var backgroundName :String;
    public var mapSizeX :int;
    public var mapSizeY :int;
    public var scaleSprites :Boolean;
    public var spellDropLoc :Vector2;
    public var baseLocs :Array = [];

    public static function fromXml (xml :XML) :MapSettingsData
    {
        var data :MapSettingsData = new MapSettingsData();

        data.backgroundName = XmlReader.getAttributeAsString(xml, "backgroundName");
        data.mapSizeX = XmlReader.getAttributeAsUint(xml, "mapSizeX", Constants.BATTLE_WIDTH);
        data.mapSizeY = XmlReader.getAttributeAsUint(xml, "mapSizeY", Constants.BATTLE_HEIGHT);
        data.scaleSprites = XmlReader.getAttributeAsBoolean(xml, "scaleSprites", false);

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
