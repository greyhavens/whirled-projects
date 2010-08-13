//
// $Id$

package popcraft.gamedata {

import com.threerings.geom.Vector2;
import com.threerings.util.XmlUtil;

public class BaseLocationData
{
    public var loc :Vector2 = new Vector2();
    public var team :int;

    public static function fromXml (xml :XML) :BaseLocationData
    {
        var data :BaseLocationData = new BaseLocationData();
        data.loc.x = XmlUtil.getNumberAttr(xml, "x");
        data.loc.y = XmlUtil.getNumberAttr(xml, "y");
        data.team = XmlUtil.getIntAttr(xml, "team");

        return data;
    }

}

}
