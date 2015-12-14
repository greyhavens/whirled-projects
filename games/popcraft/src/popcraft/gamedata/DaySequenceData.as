//
// $Id$

package popcraft.gamedata {

import com.threerings.flashbang.util.IntRange;
import com.threerings.flashbang.util.NumRange;
import com.threerings.flashbang.util.Rand;
import com.threerings.util.XmlUtil;

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

        data.repeatWaves = XmlUtil.getBooleanAttr(xmlData, "repeatWaves");

        var totalWaveDelay :Number = 0;
        for each (var waveData :XML in xmlData.Wave) {
            var uwd :UnitWaveData = UnitWaveData.fromXml(waveData, totalWaveDelay);
            totalWaveDelay += uwd.delayBefore;
            data.unitWaves.push(uwd);
        }

        var noticeSpellDropAfterMin :Number = XmlUtil.getNumberAttr(xmlData,
            "noticeSpellDropAfterMin", -1);
        var noticeSpellDropAfterMax :Number = XmlUtil.getNumberAttr(xmlData,
            "noticeSpellDropAfterMax", -1);
        data.noticeSpellDropAfter = new NumRange(
            noticeSpellDropAfterMin,
            noticeSpellDropAfterMax,
            Rand.STREAM_GAME);

        var spellDropCourierGroupSizeMin :int = XmlUtil.getIntAttr(xmlData,
            "spellDropCourierGroupSizeMin", -1);
        var spellDropCourierGroupSizeMax :int = XmlUtil.getIntAttr(xmlData,
            "spellDropCourierGroupSizeMax", -1);
        data.spellDropCourierGroupSize = new IntRange(
            spellDropCourierGroupSizeMin,
            spellDropCourierGroupSizeMax,
            Rand.STREAM_GAME);

        return data;
    }
}
}
