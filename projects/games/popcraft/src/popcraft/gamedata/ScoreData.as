//
// $Id$

package popcraft.gamedata {

import com.threerings.util.XmlUtil;

import popcraft.*;

public class ScoreData
{
    public var pointsPerExtraMultiplier :int;
    public var pointsPerResource :int;
    public var pointsPerOpponentKill :int;
    public var pointsPerCreatureKill :Array = []; // Array<int> - score for each unit type

    public function clone () :ScoreData
    {
        var theClone :ScoreData = new ScoreData();
        theClone.pointsPerExtraMultiplier = pointsPerExtraMultiplier;
        theClone.pointsPerResource = pointsPerResource;
        theClone.pointsPerOpponentKill = pointsPerOpponentKill;
        theClone.pointsPerCreatureKill = pointsPerCreatureKill.slice();
        return theClone;
    }

    public static function fromXml (xml :XML, defaults :ScoreData = null) :ScoreData
    {
        var useDefaults :Boolean = (defaults != null);
        var data :ScoreData = (useDefaults ? defaults : new ScoreData);

        data.pointsPerExtraMultiplier = XmlUtil.getIntAttr(xml, "pointsPerExtraMultiplier",
            (useDefaults ? defaults.pointsPerExtraMultiplier : undefined));
        data.pointsPerResource = XmlUtil.getIntAttr(xml, "pointsPerResource",
            (useDefaults ? defaults.pointsPerResource : undefined));
        data.pointsPerOpponentKill = XmlUtil.getIntAttr(xml, "pointsPerOpponentKill",
            (useDefaults ? defaults.pointsPerOpponentKill : undefined));

        // init pointsPerCreatureKill
        for (var ii :int = data.pointsPerCreatureKill.length;
             ii < Constants.CREATURE_UNIT_NAMES.length; ++ii) {
            data.pointsPerCreatureKill.push(0);
        }

        for each (var unitXml :XML in xml.PointsPerCreatureKill.Unit) {
            var type :int = XmlUtil.getStringArrayAttr(
                unitXml, "type", Constants.CREATURE_UNIT_NAMES);
            var points :int = XmlUtil.getIntAttr(unitXml, "points",
                (useDefaults ? defaults[type] : 0));
            data.pointsPerCreatureKill[type] = points;
        }

        return data;
    }
}

}
