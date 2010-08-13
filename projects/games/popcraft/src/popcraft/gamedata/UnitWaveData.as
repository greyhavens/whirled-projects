//
// $Id$

package popcraft.gamedata {

import com.threerings.util.XmlUtil;

import popcraft.*;
import popcraft.util.*;

public class UnitWaveData
{
    public var delayBefore :Number = 0;
    public var spellCastChance :Number = 0;
    public var units :Array = [];
    public var targetPlayerName :String;

    public static function fromXml (xmlData :XML, totalDelay :Number) :UnitWaveData
    {
        var unitWave :UnitWaveData = new UnitWaveData();

        if (XmlUtil.hasAttribute(xmlData, "absoluteDelay")) {
            var absoluteDelay :Number = XmlUtil.getNumberAttr(xmlData, "absoluteDelay");
            unitWave.delayBefore = Math.max(absoluteDelay - totalDelay, 0.1);
        } else {
            unitWave.delayBefore = XmlUtil.getNumberAttr(xmlData, "delayBefore");
        }

        unitWave.spellCastChance = XmlUtil.getNumberAttr(xmlData, "spellCastChance", 0);

        for each (var unitNode :XML in xmlData.Unit) {
            var unitType :int = XmlUtil.getStringArrayAttr(unitNode, "type",
                Constants.CREATURE_UNIT_NAMES);
            var count :int = XmlUtil.getUintAttr(unitNode, "count");
            var max :int = XmlUtil.getIntAttr(unitNode, "max", -1);

            unitWave.units.push(unitType);
            unitWave.units.push(count);
            unitWave.units.push(max);
        }

        unitWave.targetPlayerName = XmlUtil.getStringAttr(xmlData, "targetPlayerName",
            null);

        return unitWave;
    }
}

}
