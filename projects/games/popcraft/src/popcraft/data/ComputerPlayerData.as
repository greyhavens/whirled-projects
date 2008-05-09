package popcraft.data {

import com.whirled.contrib.simplegame.util.IntRange;
import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

import popcraft.util.*;

public class ComputerPlayerData
{
    public var baseHealth :int;
    public var team :uint;
    public var noticeSpellDropAfter :NumRange;
    public var spellDropCourierGroupSize :IntRange;
    public var initialDays :Array = [];
    public var repeatingDays :Array = [];

    public function get lookForSpellDrops () :Boolean
    {
        return (noticeSpellDropAfter.max >= 0);
    }

    public static function fromXml (xmlData :XML) :ComputerPlayerData
    {
        var computerPlayer :ComputerPlayerData = new ComputerPlayerData();

        computerPlayer.baseHealth = XmlReader.getAttributeAsInt(xmlData, "baseHealth");
        computerPlayer.team = XmlReader.getAttributeAsUint(xmlData, "team");

        var noticeSpellDropAfterMin :Number = XmlReader.getAttributeAsNumber(xmlData, "noticeSpellDropAfterMin", -1);
        var noticeSpellDropAfterMax :Number = XmlReader.getAttributeAsNumber(xmlData, "noticeSpellDropAfterMax", -1);
        computerPlayer.noticeSpellDropAfter = new NumRange(
            noticeSpellDropAfterMin,
            noticeSpellDropAfterMax,
            Rand.STREAM_GAME);

        var spellDropCourierGroupSizeMin :int = XmlReader.getAttributeAsInt(xmlData, "spellDropCourierGroupSizeMin", -1);
        var spellDropCourierGroupSizeMax :int = XmlReader.getAttributeAsInt(xmlData, "spellDropCourierGroupSizeMax", -1);
        computerPlayer.spellDropCourierGroupSize = new IntRange(
            spellDropCourierGroupSizeMin,
            spellDropCourierGroupSizeMax + 1, // IntRange returns values in [min, max); what we want here is [min, max]
            Rand.STREAM_GAME);

        for each (var initialDayData :XML in xmlData.InitialDays.Day) {
            computerPlayer.initialDays.push(DaySequenceData.fromXml(initialDayData));
        }

        for each (var repeatingDayData :XML in xmlData.RepeatingDays.Day) {
            computerPlayer.repeatingDays.push(DaySequenceData.fromXml(repeatingDayData));
        }

        return computerPlayer;
    }
}

}
