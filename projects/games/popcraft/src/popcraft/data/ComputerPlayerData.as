package popcraft.data {

import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.DisplayObject;

import popcraft.*;
import popcraft.sp.ComputerPlayer;
import popcraft.util.*;

public class ComputerPlayerData
{
    public var playerName :String;
    public var playerHeadshotName :String;
    public var baseHealth :int;
    public var baseStartHealth :int;
    public var invincible :Boolean;
    public var team :int;
    public var initialDays :Array = [];
    public var repeatingDays :Array = [];
    public var startingCreatureSpells :Array = [];

    public function get playerHeadshot () :DisplayObject
    {
        return ImageResource.instantiateBitmap(playerHeadshotName);
    }

    public static function fromXml (xml :XML, data :ComputerPlayerData = null) :ComputerPlayerData
    {
        var computerPlayer :ComputerPlayerData = (data != null ? data : new ComputerPlayerData());

        computerPlayer.playerName = XmlReader.getStringAttr(xml, "playerName");
        computerPlayer.playerHeadshotName = XmlReader.getStringAttr(xml, "playerHeadshotName");
        computerPlayer.baseHealth = XmlReader.getIntAttr(xml, "baseHealth");
        computerPlayer.baseStartHealth = XmlReader.getIntAttr(xml, "baseStartHealth",
            computerPlayer.baseHealth);
        computerPlayer.invincible = XmlReader.getBooleanAttr(xml, "invincible", false);
        computerPlayer.team = XmlReader.getUintAttr(xml, "team");

        for each (var initialDayData :XML in xml.InitialDays.Day) {
            computerPlayer.initialDays.push(DaySequenceData.fromXml(initialDayData));
        }

        for each (var repeatingDayData :XML in xml.RepeatingDays.Day) {
            computerPlayer.repeatingDays.push(DaySequenceData.fromXml(repeatingDayData));
        }

        // init spells
        for (var spellType :int = 0; spellType < Constants.CREATURE_SPELL_TYPE__LIMIT; ++spellType) {
            computerPlayer.startingCreatureSpells.push(0);
        }

        // read spells
        for each (var spellData :XML in xml.InitialSpells.Spell) {
            spellType = XmlReader.getEnumAttr(spellData, "type", Constants.CREATURE_SPELL_NAMES);
            var amount :int = XmlReader.getUintAttr(spellData, "amount");
            computerPlayer.startingCreatureSpells[spellType] = amount;
        }

        return computerPlayer;
    }
}

}
