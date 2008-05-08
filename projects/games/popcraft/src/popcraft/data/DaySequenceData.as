package popcraft.data {

import popcraft.util.XmlReader;

public class DaySequenceData
{
    public var unitWaves :Array = [];
    public var repeatWaves :Boolean;

    public static function fromXml (xmlData :XML) :DaySequenceData
    {
        var data :DaySequenceData = new DaySequenceData();

        data.repeatWaves = XmlReader.getAttributeAsBoolean(xmlData, "repeatWaves");

        var totalWaveDelay :Number = 0;
        for each (var waveData :XML in xmlData.Wave) {
            var uwd :UnitWaveData = UnitWaveData.fromXml(waveData, totalWaveDelay);
            totalWaveDelay += uwd.delayBefore;
            data.unitWaves.push(uwd);
        }

        return data;
    }
}
}
