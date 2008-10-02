package popcraft.data {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.util.XmlReader;

public class MapSettingsData
{
    public var backgroundName :String;
    public var mapScaleX :Number;
    public var mapScaleY :Number;
    public var scaleSprites :Boolean;
    public var spellDropLoc :Vector2;
    public var baseLocs :Array = []; // of BaseLocationDatas

    public static function fromXml (xml :XML) :MapSettingsData
    {
        var data :MapSettingsData = new MapSettingsData();

        data.backgroundName = XmlReader.getAttributeAsString(xml, "backgroundName");
        data.mapScaleX = XmlReader.getAttributeAsNumber(xml, "mapScaleX", 1);
        data.mapScaleY = XmlReader.getAttributeAsNumber(xml, "mapScaleY", 1);
        data.scaleSprites = XmlReader.getAttributeAsBoolean(xml, "scaleSprites", false);

        var spellDropXml :XML = XmlReader.getSingleChild(xml, "SpellDropLocation", null);
        if (null != spellDropXml) {
            var x :Number = XmlReader.getAttributeAsNumber(spellDropXml, "x");
            var y :Number = XmlReader.getAttributeAsNumber(spellDropXml, "y");
            data.spellDropLoc = new Vector2(x, y);
        }

        for each (var baseLocXml :XML in xml.BaseLocation) {
            data.baseLocs.push(BaseLocationData.fromXml(baseLocXml));
        }

        return data;
    }

    /**
     * If one exists, returns the first BaseLocationData for the given team, and removes that
     * data from the baseLocs Array. This should usually be performed on a copy of the
     * MapSettingsData's baseLocs Array.
     */
    public static function getNextBaseLocForTeam (baseLocs :Array, teamId :int) :BaseLocationData
    {
        var data :BaseLocationData;
        for (var ii :int = 0; ii < baseLocs.length; ++ii) {
            var thisBaseLoc :BaseLocationData = baseLocs[ii];
            if (thisBaseLoc.team == teamId) {
                data = thisBaseLoc;
                baseLocs.splice(ii, 1);
                break;
            }
        }

        return data;
    }
}

}
