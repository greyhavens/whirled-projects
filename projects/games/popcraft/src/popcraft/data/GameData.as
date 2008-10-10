package popcraft.data {

import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.util.*;

import popcraft.*;
import popcraft.util.*;

public class GameData
{
    public var resourceClearValueTable :IntValueTable;

    public var pointsPerResource :int;

    public var dayLength :Number;
    public var nightLength :Number;
    public var dawnWarning :Number;
    public var initialDayPhase :int;
    public var disableDiurnalCycle :Boolean;
    public var enableEclipse :Boolean;
    public var eclipseLength :Number;

    public var spellDropTime :NumRange;
    public var spellDropScatter :NumRange;
    public var spellDropCenterOffset :NumRange;
    public var maxLosingPlayerSpellDropShift :Number;

    public var minResourceAmount :int;
    public var maxResourceAmount :int;
    public var maxSpellsPerType :int;

    public var resources :Array = [];
    public var units :Array = [];
    public var spells :Array = [];

    public var playerDisplayDatas :HashMap = new HashMap(); // Map<String, PlayerDisplayData>

    public function getPlayerDisplayData (playerName :String) :PlayerDisplayData
    {
        var data :PlayerDisplayData = playerDisplayDatas.get(playerName);
        return (data != null ? data : PlayerDisplayData.unknown);
    }

    public function clone () :GameData
    {
        var theClone :GameData = new GameData();

        theClone.resourceClearValueTable = resourceClearValueTable.clone();

        theClone.pointsPerResource = pointsPerResource;
        theClone.dayLength = dayLength;
        theClone.nightLength = nightLength;
        theClone.dawnWarning = dawnWarning;
        theClone.initialDayPhase = initialDayPhase;
        theClone.disableDiurnalCycle = disableDiurnalCycle;
        theClone.enableEclipse = enableEclipse;
        theClone.eclipseLength = eclipseLength;
        theClone.spellDropTime = spellDropTime.clone();
        theClone.spellDropScatter = spellDropScatter.clone();
        theClone.spellDropCenterOffset = spellDropCenterOffset.clone();
        theClone.maxLosingPlayerSpellDropShift = maxLosingPlayerSpellDropShift;
        theClone.minResourceAmount = minResourceAmount;
        theClone.maxResourceAmount = maxResourceAmount;
        theClone.maxSpellsPerType = maxSpellsPerType;

        for each (var resData :ResourceData in resources) {
            theClone.resources.push(resData.clone());
        }

        for each (var unitData :UnitData in units) {
            theClone.units.push(unitData.clone());
        }

        for each (var spellData :SpellData in spells) {
            theClone.spells.push(spellData.clone());
        }

        for each (var playerDisplayData :PlayerDisplayData in playerDisplayDatas.values()) {
            theClone.playerDisplayDatas.put(playerDisplayData.dataName, playerDisplayData.clone());
        }

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :GameData = null) :GameData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var gameData :GameData = (useDefaults ? inheritFrom : new GameData());

        if (!useDefaults || XmlReader.hasChild(xml, "PuzzleClearValueTable")) {
            gameData.resourceClearValueTable = IntValueTable.fromXml(
                XmlReader.getSingleChild(xml, "PuzzleClearValueTable"));
        }

        gameData.pointsPerResource = XmlReader.getIntAttr(xml, "pointsPerResource",
            (useDefaults ? gameData.pointsPerResource : undefined));

        gameData.dayLength = XmlReader.getNumberAttr(xml, "dayLength",
            (useDefaults ? gameData.dayLength : undefined));
        gameData.nightLength = XmlReader.getNumberAttr(xml, "nightLength",
            (useDefaults ? gameData.nightLength : undefined));
        gameData.dawnWarning = XmlReader.getNumberAttr(xml, "dawnWarning",
            (useDefaults ? gameData.dawnWarning : undefined));
        gameData.initialDayPhase = XmlReader.getEnumAttr(xml, "initialDayPhase",
            Constants.DAY_PHASE_NAMES, (useDefaults ? gameData.initialDayPhase : undefined));
        gameData.disableDiurnalCycle = XmlReader.getBooleanAttr(xml, "disableDiurnalCycle",
            (useDefaults ? gameData.disableDiurnalCycle : undefined));
        gameData.enableEclipse = XmlReader.getBooleanAttr(xml, "enableEclipse",
            (useDefaults ? gameData.enableEclipse : undefined));
        gameData.eclipseLength = XmlReader.getNumberAttr(xml, "eclipseLength",
            (useDefaults ? gameData.eclipseLength : undefined));

        var spellDropTimeMin :Number = XmlReader.getNumberAttr(xml, "spellDropTimeMin",
            (useDefaults ? gameData.spellDropTime.min : undefined));
        var spellDropTimeMax :Number = XmlReader.getNumberAttr(xml, "spellDropTimeMax",
            (useDefaults ? gameData.spellDropTime.max : undefined));
        gameData.spellDropTime = new NumRange(spellDropTimeMin, spellDropTimeMax, Rand.STREAM_GAME);

        var spellDropScatterMin :Number = XmlReader.getNumberAttr(xml, "spellDropScatterMin",
            (useDefaults ? gameData.spellDropScatter.min : undefined));
        var spellDropScatterMax :Number = XmlReader.getNumberAttr(xml, "spellDropScatterMax",
            (useDefaults ? gameData.spellDropScatter.max : undefined));
        gameData.spellDropScatter = new NumRange(spellDropScatterMin, spellDropScatterMax,
            Rand.STREAM_GAME);

        var spellDropCenterOffsetMin :Number = XmlReader.getNumberAttr(xml,
            "spellDropCenterOffsetMin",
            (useDefaults ? gameData.spellDropCenterOffset.min : undefined));
        var spellDropCenterOffsetMax :Number = XmlReader.getNumberAttr(xml,
            "spellDropCenterOffsetMax",
            (useDefaults ? gameData.spellDropCenterOffset.max : undefined));
        gameData.spellDropCenterOffset = new NumRange(spellDropCenterOffsetMin, spellDropCenterOffsetMax, Rand.STREAM_GAME);

        gameData.maxLosingPlayerSpellDropShift = XmlReader.getNumberAttr(xml,
            "maxLosingPlayerSpellDropShift",
            (useDefaults ? gameData.maxLosingPlayerSpellDropShift : undefined));

        gameData.minResourceAmount = XmlReader.getIntAttr(xml, "minResourceAmount",
            (useDefaults ? gameData.minResourceAmount : undefined));
        gameData.maxResourceAmount = XmlReader.getIntAttr(xml, "maxResourceAmount",
            (useDefaults ? gameData.maxResourceAmount : undefined));
        gameData.maxSpellsPerType = XmlReader.getIntAttr(xml, "maxSpellsPerType",
            (useDefaults ? gameData.maxSpellsPerType : undefined));

        // init the resource data
        for (var i :int = gameData.resources.length; i < Constants.RESOURCE_NAMES.length; ++i) {
            gameData.resources.push(null);
        }

        for each (var resourceNode :XML in xml.Resources.Resource) {
            var type :int = XmlReader.getEnumAttr(resourceNode, "type",
                Constants.RESOURCE_NAMES);
            gameData.resources[type] = ResourceData.fromXml(resourceNode,
                (useDefaults ? inheritFrom.resources[type] : null));
        }

        // init the unit data
        for (i = gameData.units.length; i < Constants.UNIT_NAMES.length; ++i) {
            gameData.units.push(null);
        }

        for each (var unitNode :XML in xml.Units.Unit) {
            type = XmlReader.getEnumAttr(unitNode, "type", Constants.UNIT_NAMES);
            gameData.units[type] = UnitData.fromXml(unitNode,
                (useDefaults ? inheritFrom.units[type] : null));
        }

        // init the spell data
        for (i = gameData.spells.length; i < Constants.SPELL_TYPE__LIMIT; ++i) {
            gameData.spells.push(null);
        }

        for each (var spellNode :XML in xml.Spells.Spell) {
            type = XmlReader.getEnumAttr(spellNode, "type", Constants.SPELL_NAMES);
            var spellClass :Class =
                (type < Constants.CREATURE_SPELL_TYPE__LIMIT ? CreatureSpellData : SpellData);
            gameData.spells[type] = spellClass.fromXml(spellNode,
                (useDefaults ? inheritFrom.spells[type] : null));
        }

        // read PlayerDisplayData
        for each (var playerDisplayXml :XML in xml.PlayerDisplayDatas.PlayerDisplay) {
            var name :String = XmlReader.getStringAttr(playerDisplayXml, "name");
            var inheritDisplayData :PlayerDisplayData;
            if (inheritFrom != null) {
                inheritDisplayData = inheritFrom.getPlayerDisplayData(name);
            }
            gameData.playerDisplayDatas.put(name,
                PlayerDisplayData.fromXml(playerDisplayXml, inheritDisplayData));
        }

        return gameData;
    }

    public function generateUnitReport () :String
    {
        var report :String = "";

        for each (var srcUnit :UnitData in units) {

            if (srcUnit.name == "workshop") {
                continue;
            }

            report += srcUnit.name;

            var weapon :UnitWeaponData = srcUnit.weapon;

            var rangeMin :Number = weapon.damageRange.min;
            var rangeMax :Number = weapon.damageRange.max;
            var damageType :int = weapon.damageType;

            report += "\nWeapon damage range: (" + rangeMin + ", " + rangeMax + ")";

            for each (var dstUnit :UnitData in units) {
                var dmgMin :Number = (null != dstUnit.armor ? dstUnit.armor.getDamage(damageType,
                    rangeMin) : Number.NEGATIVE_INFINITY);
                var dmgMax :Number = (null != dstUnit.armor ? dstUnit.armor.getDamage(damageType,
                    rangeMax) : Number.NEGATIVE_INFINITY);
                // dot == damage over time
                var dotMin :Number = dmgMin / weapon.cooldown;
                var dotMax :Number = dmgMax / weapon.cooldown;
                // ttk == time-to-kill
                var ttkMin :Number = dstUnit.maxHealth / dotMax;
                var ttkMax :Number = dstUnit.maxHealth / dotMin;
                var ttkAvg :Number = (ttkMin + ttkMax) / 2;

                report += "\nvs " + dstUnit.name + ":"
                report += " (" + dmgMin.toFixed(2) + ", " + dmgMax.toFixed(2) + ")";
                report += " DOT: (" + dotMin.toFixed(2) + "/s, " + dotMax.toFixed(2) + "/s)";
                report += " avg time-to-kill: " + ttkAvg.toFixed(2);
            }

            report += "\n\n";
        }

        return report;
    }
}

}
