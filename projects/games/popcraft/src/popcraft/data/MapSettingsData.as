package popcraft.data {

import com.threerings.geom.Vector2;
import com.threerings.util.XmlUtil;

import popcraft.*;

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

        data.backgroundName = XmlUtil.getStringAttr(xml, "backgroundName");
        data.mapScaleX = XmlUtil.getNumberAttr(xml, "mapScaleX", 1);
        data.mapScaleY = XmlUtil.getNumberAttr(xml, "mapScaleY", 1);
        data.scaleSprites = XmlUtil.getBooleanAttr(xml, "scaleSprites", false);

        var spellDropXml :XML = XmlUtil.getSingleChild(xml, "SpellDropLocation", null);
        if (null != spellDropXml) {
            var x :Number = XmlUtil.getNumberAttr(spellDropXml, "x");
            var y :Number = XmlUtil.getNumberAttr(spellDropXml, "y");
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
