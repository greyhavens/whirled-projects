package popcraft.data {

import popcraft.*;
import popcraft.util.*;

public class UnitWave
{
    public var delayBefore :Number = 0;
    public var units :Array = [];

    public static function fromXml (xmlData :XML) :UnitWave
    {
        var unitWave :UnitWave = new UnitWave();

        unitWave.delayBefore = XmlReader.getAttributeAsNumber(xmlData, "delayBefore");

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
