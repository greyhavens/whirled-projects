package popcraft.data {

import popcraft.util.XmlReader;

import com.whirled.contrib.simplegame.util.IntRange;
import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

public class DaySequenceData
{
    public var unitWaves :Array = [];
    public var repeatWaves :Boolean;
    public var noticeSpellDropAfter :NumRange;
    public var spellDropCourierGroupSize :IntRange;

    public function get lookForSpellDrops () :Boolean
    {
        return (noticeSpellDropAfter.max >= 0);
    }

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

        var noticeSpellDropAfterMin :Number = XmlReader.getAttributeAsNumber(xmlData,
            "noticeSpellDropAfterMin", -1);
        var noticeSpellDropAfterMax :Number = XmlReader.getAttributeAsNumber(xmlData,
            "noticeSpellDropAfterMax", -1);
        data.noticeSpellDropAfter = new NumRange(
            noticeSpellDropAfterMin,
            noticeSpellDropAfterMax,
            Rand.STREAM_GAME);

        var spellDropCourierGroupSizeMin :int = XmlReader.getAttributeAsInt(xmlData,
            "spellDropCourierGroupSizeMin", -1);
        var spellDropCourierGroupSizeMax :int = XmlReader.getAttributeAsInt(xmlData,
            "spellDropCourierGroupSizeMax", -1);
        data.spellDropCourierGroupSize = new IntRange(
            spellDropCourierGroupSizeMin,
            spellDropCourierGroupSizeMax + 1, // IntRange returns values in [min, max); what we want here is [min, max]
            Rand.STREAM_GAME);

        return data;
    }
}
}
