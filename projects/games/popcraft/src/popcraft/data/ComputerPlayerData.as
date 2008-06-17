package popcraft.data {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.util.*;

public class ComputerPlayerData
{
    public var playerName :String;
    public var baseHealth :int;
    public var baseStartHealth :int;
    public var invincible :Boolean;
    public var team :int;
    public var baseLoc :Vector2;
    public var initialDays :Array = [];
    public var repeatingDays :Array = [];
    public var startingCreatureSpells :Array = [];

    public static function fromXml (xmlData :XML) :ComputerPlayerData
    {
        var computerPlayer :ComputerPlayerData = new ComputerPlayerData();

        computerPlayer.playerName = XmlReader.getAttributeAsString(xmlData, "playerName");
        computerPlayer.baseHealth = XmlReader.getAttributeAsInt(xmlData, "baseHealth");
        computerPlayer.baseStartHealth = XmlReader.getAttributeAsInt(xmlData, "baseStartHealth", computerPlayer.baseHealth);
        computerPlayer.invincible = XmlReader.getAttributeAsBoolean(xmlData, "invincible", false);
        computerPlayer.team = XmlReader.getAttributeAsUint(xmlData, "team");

        var baseLocXml :XML = XmlReader.getSingleChild(xmlData, "BaseLocation");
        var baseX :Number = XmlReader.getAttributeAsNumber(baseLocXml, "x");
        var baseY :Number = XmlReader.getAttributeAsNumber(baseLocXml, "y");
        computerPlayer.baseLoc = new Vector2(baseX, baseY);

        for each (var initialDayData :XML in xmlData.InitialDays.Day) {
            computerPlayer.initialDays.push(DaySequenceData.fromXml(initialDayData));
        }

        for each (var repeatingDayData :XML in xmlData.RepeatingDays.Day) {
            computerPlayer.repeatingDays.push(DaySequenceData.fromXml(repeatingDayData));
        }

        // init spells
        for (var spellType :int = 0; spellType < Constants.CREATURE_SPELL_TYPE__LIMIT; ++spellType) {
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
