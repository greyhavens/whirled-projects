package popcraft.data {

import com.threerings.util.ArrayUtil;

import popcraft.*;
import popcraft.util.*;

public class LevelData
{
    public var parDays :int;
    public var levelCompletionBonus :int;
    public var backgroundName :String;
    public var introText :String;
    public var newCreatureType :int;
    public var newSpellType :int;

    public var playerName :String;
    public var playerBaseHealth :int;
    public var playerBaseStartHealth :int;

    public var availableUnits :Array = [];
    public var availableSpells :Array = [];
    public var computers :Array = [];
    public var initialResources :Array = [];
    public var initialSpells :Array = [];

    public var gameDataOverride :GameData;

    public function isAvailableUnit (unitType :uint) :Boolean
    {
        return ArrayUtil.contains(availableUnits, unitType);
    }

    public function isAvailableSpell (spellType :uint) :Boolean
    {
        return ArrayUtil.contains(availableSpells, spellType);
    }

    public static function fromXml (xml :XML) :LevelData
    {
        var level :LevelData = new LevelData();

        // does the level override game data?
        var gameDataOverrideNode :XML = xml.GameDataOverride[0];
        if (null != gameDataOverrideNode) {
            level.gameDataOverride = GameData.fromXml(gameDataOverrideNode, AppContext.defaultGameData.clone());
        }

        level.parDays = XmlReader.getAttributeAsInt(xml, "parDays");
        level.levelCompletionBonus = XmlReader.getAttributeAsInt(xml, "levelCompletionBonus", 0);
        level.backgroundName = XmlReader.getAttributeAsString(xml, "backgroundName");
        level.introText = XmlReader.getAttributeAsString(xml, "introText");
        level.newCreatureType = XmlReader.getAttributeAsEnum(xml, "newCreatureType", Constants.CREATURE_UNIT_NAMES, -1);
        level.newSpellType = XmlReader.getAttributeAsEnum(xml, "newSpellType", Constants.SPELL_NAMES, -1);

        level.playerName = XmlReader.getAttributeAsString(xml, "playerName");
        level.playerBaseHealth = XmlReader.getAttributeAsInt(xml, "playerBaseHealth");
        level.playerBaseStartHealth = XmlReader.getAttributeAsInt(xml, "playerBaseStartHealth", level.playerBaseHealth);

        // parse the available units
        for each (var unitData :XML in xml.AvailableUnits.Unit) {
            level.availableUnits.push(XmlReader.getAttributeAsEnum(unitData, "type", Constants.CREATURE_UNIT_NAMES));
        }

        // parse available spells
        for each (var spellData :XML in xml.AvailableSpells.Spell) {
            level.availableSpells.push(XmlReader.getAttributeAsEnum(spellData, "type", Constants.SPELL_NAMES));
        }

        // parse the computer players
        for each (var computerData :XML in xml.Computer) {
            level.computers.push(ComputerPlayerData.fromXml(computerData));
        }

        // parse the initial resources
        level.initialResources = ArrayUtil.create(Constants.RESOURCE__LIMIT, 0);
        for each (var resourceNode :XML in xml.InitialResources.Resource) {
            var type :uint = XmlReader.getAttributeAsEnum(resourceNode, "type", Constants.RESOURCE_NAMES);
            var amount :int = XmlReader.getAttributeAsUint(resourceNode, "amount");
            level.initialResources[type] = amount;
        }

        // parse the initial spells
        level.initialSpells = ArrayUtil.create(Constants.SPELL_TYPE__LIMIT, 0);
        for each (var spellNode :XML in xml.InitialSpells.Spell) {
            type = XmlReader.getAttributeAsEnum(spellNode, "type", Constants.SPELL_NAMES);
            amount = XmlReader.getAttributeAsUint(spellNode, "amount");
            level.initialSpells[type] = amount;
        }

        return level;
    }
}

}
