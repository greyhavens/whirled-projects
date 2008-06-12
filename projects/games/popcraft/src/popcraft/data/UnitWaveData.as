package popcraft.data {

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

        if (XmlReader.hasAttribute(xmlData, "absoluteDelay")) {
            var absoluteDelay :Number = XmlReader.getAttributeAsNumber(xmlData, "absoluteDelay");
            unitWave.delayBefore = Math.max(absoluteDelay - totalDelay, 0.1);
        } else {
            unitWave.delayBefore = XmlReader.getAttributeAsNumber(xmlData, "delayBefore");
        }

        unitWave.spellCastChance = XmlReader.getAttributeAsNumber(xmlData, "spellCastChance", 0);

        for each (var unitNode :XML in xmlData.Unit) {
            var unitType :uint = XmlReader.getAttributeAsEnum(unitNode, "type", Constants.CREATURE_UNIT_NAMES);
            var count :int = XmlReader.getAttributeAsUint(unitNode, "count");
            var max :int = XmlReader.getAttributeAsInt(unitNode, "max", -1);

            unitWave.units.push(unitType);
            unitWave.units.push(count);
            unitWave.units.push(max);
        }

        unitWave.targetPlayerName = XmlReader.getAttributeAsString(xmlData, "targetPlayerName", null);

        return unitWave;
    }
}

}
