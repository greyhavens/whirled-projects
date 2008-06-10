package popcraft.data {

import popcraft.*;
import popcraft.util.*;

public class ComputerPlayerData
{
    public var playerName :String;
    public var baseHealth :int;
    public var baseStartHealth :int;
    public var team :uint;
    public var initialDays :Array = [];
    public var repeatingDays :Array = [];
    public var startingCreatureSpells :Array = [];

    public static function fromXml (xmlData :XML) :ComputerPlayerData
    {
        var computerPlayer :ComputerPlayerData = new ComputerPlayerData();

        computerPlayer.playerName = XmlReader.getAttributeAsString(xmlData, "playerName");
        computerPlayer.baseHealth = XmlReader.getAttributeAsInt(xmlData, "baseHealth");
        computerPlayer.baseStartHealth = XmlReader.getAttributeAsInt(xmlData, "baseStartHealth", computerPlayer.baseHealth);
        computerPlayer.team = XmlReader.getAttributeAsUint(xmlData, "team");

        for each (var initialDayData :XML in xmlData.InitialDays.Day) {
            computerPlayer.initialDays.push(DaySequenceData.fromXml(initialDayData));
        }

        for each (var repeatingDayData :XML in xmlData.RepeatingDays.Day) {
            computerPlayer.repeatingDays.push(DaySequenceData.fromXml(repeatingDayData));
        }

        // init spells
        for (var spellType :uint = 0; spellType < Constants.CREATURE_SPELL_TYPE__LIMIT; ++spellType) {
            computerPlayer.startingCreatureSpells.push(0);
        }

        // read spells
        for each (var spellData :XML in xmlData.InitialSpells.Spell) {
            spellType = XmlReader.getAttributeAsEnum(spellData, "type", Constants.CREATURE_SPELL_NAMES);
            var amount :int = XmlReader.getAttributeAsUint(spellData, "amount");
            computerPlayer.startingCreatureSpells[spellType] = amount;
        }

        return computerPlayer;
    }
}

}
