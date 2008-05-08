package popcraft.data {

import popcraft.util.*;

public class ComputerPlayerData
{
    public var baseHealth :int;
    public var team :uint;
    public var initialDays :Array = [];
    public var repeatingDays :Array = [];

    public static function fromXml (xmlData :XML) :ComputerPlayerData
    {
        var computerPlayer :ComputerPlayerData = new ComputerPlayerData();

        computerPlayer.baseHealth = XmlReader.getAttributeAsInt(xmlData, "baseHealth");
        computerPlayer.team = XmlReader.getAttributeAsUint(xmlData, "team");

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
