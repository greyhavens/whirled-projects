package popcraft.data {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.DisplayObject;

import popcraft.*;
import popcraft.util.*;

public class LevelData
{
    public var levelCompletionBonus :int;
    public var expertCompletionBonus :int;
    public var expertCompletionDays :int;
    public var maxResourcesScore :int;
    public var introText :String;
    public var introText2 :String;
    public var newCreatureType :int;
    public var newSpellType :int;

    public var playerName :String;
    public var playerHeadshotName :String;
    public var playerBaseHealth :int;
    public var playerBaseStartHealth :int;

    public var levelHints :Array = [];
    public var availableUnits :Array = [];
    public var availableSpells :Array = [];
    public var computers :Array = [];
    public var initialResources :Array = [];
    public var initialSpells :Array = [];

    public var mapSettings :MapSettingsData;

    public var gameDataOverride :GameData;

    public function get playerHeadshot () :DisplayObject
    {
        return ImageResource.instantiateBitmap(playerHeadshotName);
    }

    public function isAvailableUnit (unitType :int) :Boolean
    {
        return ArrayUtil.contains(availableUnits, unitType);
    }

    public function isAvailableSpell (spellType :int) :Boolean
    {
        return ArrayUtil.contains(availableSpells, spellType);
    }

    public static function fromXml (xml :XML) :LevelData
    {
        var level :LevelData = new LevelData();

        // does the level override game data?
        var gameDataOverrideNode :XML = xml.GameDataOverride[0];
        if (null != gameDataOverrideNode) {
            level.gameDataOverride = GameData.fromXml(gameDataOverrideNode,
                AppContext.defaultGameData.clone());
        }

        level.levelCompletionBonus = XmlReader.getIntAttr(xml, "levelCompletionBonus");
        level.expertCompletionBonus = XmlReader.getIntAttr(xml, "expertCompletionBonus");
        level.expertCompletionDays = XmlReader.getIntAttr(xml, "expertCompletionDays");
        // only used on levels 1 and 2 to prevent infinite resource farming
        level.maxResourcesScore = XmlReader.getIntAttr(xml, "maxResourcesScore", -1);
        level.introText = XmlReader.getStringAttr(xml, "introText");
        level.introText2 = XmlReader.getStringAttr(xml, "introText2", level.introText);
        level.newCreatureType = XmlReader.getEnumAttr(xml, "newCreatureType",
            Constants.PLAYER_CREATURE_UNIT_NAMES, -1);
        level.newSpellType = XmlReader.getEnumAttr(xml, "newSpellType",
            Constants.CASTABLE_SPELL_NAMES, -1);

        level.playerName = XmlReader.getStringAttr(xml, "playerName");
        level.playerHeadshotName = XmlReader.getStringAttr(xml, "playerHeadshotName");
        level.playerBaseHealth = XmlReader.getIntAttr(xml, "playerBaseHealth");
        level.playerBaseStartHealth = XmlReader.getIntAttr(xml, "playerBaseStartHealth",
            level.playerBaseHealth);

        // level hints
        for each (var hintData :XML in xml.Hints.Hint) {
            level.levelHints.push(String(hintData));
        }

        // parse the available units and spells
        level.availableUnits = DataUtils.parseCreatureTypes(xml.AvailableUnits[0]);
        level.availableSpells = DataUtils.parseCastableSpellTypes(xml.AvailableSpells[0]);

        // parse the computer players
        for each (var computerData :XML in xml.Computer) {
            level.computers.push(ComputerPlayerData.fromXml(computerData));
        }

        // parse the initial resources
        level.initialResources = ArrayUtil.create(Constants.RESOURCE__LIMIT, 0);
        for each (var resourceNode :XML in xml.InitialResources.Resource) {
            var type :int = XmlReader.getEnumAttr(resourceNode, "type",
                Constants.RESOURCE_NAMES);
            var amount :int = XmlReader.getUintAttr(resourceNode, "amount");
            level.initialResources[type] = amount;
        }

        // parse the initial spells
        level.initialSpells = ArrayUtil.create(Constants.CASTABLE_SPELL_TYPE__LIMIT, 0);
        for each (var spellNode :XML in xml.InitialSpells.Spell) {
            type = XmlReader.getEnumAttr(spellNode, "type", Constants.CASTABLE_SPELL_NAMES);
            amount = XmlReader.getUintAttr(spellNode, "amount");
            level.initialSpells[type] = amount;
        }

        // map settings
        level.mapSettings = MapSettingsData.fromXml(XmlReader.getSingleChild(xml, "MapSettings"));

        return level;
    }
}

}
