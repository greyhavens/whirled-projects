//
// $Id$

package popcraft.data {

import com.threerings.util.XmlUtil;

public class LevelProgressionData
{
    public var levelNames :Array = [];

    public static function fromXml (xml :XML) :LevelProgressionData
    {
        var lpd :LevelProgressionData = new LevelProgressionData();

        for each (var level :XML in xml.Level) {
            lpd.levelNames.push(XmlUtil.getStringAttr(level, "name"));
        }

        return lpd;
    }

}

}
