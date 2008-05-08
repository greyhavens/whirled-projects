package popcraft.data {

import popcraft.*;
import popcraft.util.*;

public class UnitWaveData
{
    public var delayBefore :Number = 0;
    public var units :Array = [];

    public static function fromXml (xmlData :XML, totalDelay :Number) :UnitWaveData
    {
        var unitWave :UnitWaveData = new UnitWaveData();

        if (XmlReader.hasAttribute(xmlData, "absoluteDelay")) {
            var absoluteDelay :Number = XmlReader.getAttributeAsNumber(xmlData, "absoluteDelay");
            unitWave.delayBefore = Math.max(absoluteDelay - totalDelay, 0.1);
        } else {
            unitWave.delayBefore = XmlReader.getAttributeAsNumber(xmlData, "delayBefore");
        }

        for each (var unitNode :XML in xmlData.Unit) {
            var unitType :uint = XmlReader.getAttributeAsEnum(unitNode, "type", Constants.CREATURE_UNIT_NAMES);
            var count :int = XmlReader.getAttributeAsUint(unitNode, "count");

            for (var i :int = 0; i < count; ++i) {
                unitWave.units.push(unitType);
            }
        }

        return unitWave;
    }
}

}
