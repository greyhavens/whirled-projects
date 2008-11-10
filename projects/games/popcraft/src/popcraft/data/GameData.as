package popcraft.data {

import com.threerings.util.HashMap;
import com.threerings.util.SortedHashMap;
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

    // Map<String, PlayerDisplayData>
    public var playerDisplayDatas :SortedHashMap = new SortedHashMap(SortedHashMap.STRING_KEYS);

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
            theClone.playerDisplayDatas.put(playerDisplayData.playerName, playerDisplayData.clone());
        }

        return theClone;
    }

    public static function fromXml (xml :XML, defaults :GameData = null) :GameData
    {
        var useDefaults :Boolean = (null != defaults);

        var data :GameData = (useDefaults ? defaults : new GameData());

        if (!useDefaults || XmlReader.hasChild(xml, "PuzzleClearValueTable")) {
            data.resourceClearValueTable = IntValueTable.fromXml(
                XmlReader.getSingleChild(xml, "PuzzleClearValueTable"));
        }

        data.pointsPerResource = XmlReader.getIntAttr(xml, "pointsPerResource",
            (useDefaults ? defaults.pointsPerResource : undefined));

        data.dayLength = XmlReader.getNumberAttr(xml, "dayLength",
            (useDefaults ? defaults.dayLength : undefined));
        data.nightLength = XmlReader.getNumberAttr(xml, "nightLength",
            (useDefaults ? defaults.nightLength : undefined));
        data.dawnWarning = XmlReader.getNumberAttr(xml, "dawnWarning",
            (useDefaults ? defaults.dawnWarning : undefined));
        data.initialDayPhase = XmlReader.getEnumAttr(xml, "initialDayPhase",
            Constants.DAY_PHASE_NAMES, (useDefaults ? defaults.initialDayPhase : undefined));
        data.disableDiurnalCycle = XmlReader.getBooleanAttr(xml, "disableDiurnalCycle",
            (useDefaults ? defaults.disableDiurnalCycle : undefined));
        data.enableEclipse = XmlReader.getBooleanAttr(xml, "enableEclipse",
            (useDefaults ? defaults.enableEclipse : undefined));
        data.eclipseLength = XmlReader.getNumberAttr(xml, "eclipseLength",
            (useDefaults ? defaults.eclipseLength : undefined));

        var spellDropTimeMin :Number = XmlReader.getNumberAttr(xml, "spellDropTimeMin",
            (useDefaults ? defaults.spellDropTime.min : undefined));
        var spellDropTimeMax :Number = XmlReader.getNumberAttr(xml, "spellDropTimeMax",
            (useDefaults ? defaults.spellDropTime.max : undefined));
        data.spellDropTime = new NumRange(spellDropTimeMin, spellDropTimeMax, Rand.STREAM_GAME);

        var spellDropScatterMin :Number = XmlReader.getNumberAttr(xml, "spellDropScatterMin",
            (useDefaults ? defaults.spellDropScatter.min : undefined));
        var spellDropScatterMax :Number = XmlReader.getNumberAttr(xml, "spellDropScatterMax",
            (useDefaults ? defaults.spellDropScatter.max : undefined));
        data.spellDropScatter = new NumRange(spellDropScatterMin, spellDropScatterMax,
            Rand.STREAM_GAME);

        var spellDropCenterOffsetMin :Number = XmlReader.getNumberAttr(xml,
            "spellDropCenterOffsetMin",
            (useDefaults ? defaults.spellDropCenterOffset.min : undefined));
        var spellDropCenterOffsetMax :Number = XmlReader.getNumberAttr(xml,
            "spellDropCenterOffsetMax",
            (useDefaults ? defaults.spellDropCenterOffset.max : undefined));
        data.spellDropCenterOffset = new NumRange(spellDropCenterOffsetMin, spellDropCenterOffsetMax, Rand.STREAM_GAME);

        data.maxLosingPlayerSpellDropShift = XmlReader.getNumberAttr(xml,
            "maxLosingPlayerSpellDropShift",
            (useDefaults ? defaults.maxLosingPlayerSpellDropShift : undefined));

        data.minResourceAmount = XmlReader.getIntAttr(xml, "minResourceAmount",
            (useDefaults ? defaults.minResourceAmount : undefined));
        data.maxResourceAmount = XmlReader.getIntAttr(xml, "maxResourceAmount",
            (useDefaults ? defaults.maxResourceAmount : undefined));
        data.maxSpellsPerType = XmlReader.getIntAttr(xml, "maxSpellsPerType",
            (useDefaults ? defaults.maxSpellsPerType : undefined));

        // init the resource data
        for (var i :int = data.resources.length; i < Constants.RESOURCE_NAMES.length; ++i) {
            data.resources.push(null);
        }

        for each (var resourceNode :XML in xml.Resources.Resource) {
            var type :int = XmlReader.getEnumAttr(resourceNode, "type",
                Constants.RESOURCE_NAMES);
            data.resources[type] = ResourceData.fromXml(resourceNode,
                (useDefaults ? defaults.resources[type] : null));
        }

        // init the unit data
        for (i = data.units.length; i < Constants.UNIT_NAMES.length; ++i) {
            data.units.push(null);
        }

        for each (var unitNode :XML in xml.Units.Unit) {
            type = XmlReader.getEnumAttr(unitNode, "type", Constants.UNIT_NAMES);
            data.units[type] = UnitData.fromXml(unitNode,
                (useDefaults ? defaults.units[type] : null));
        }

        // init the spell data
        for (i = data.spells.length; i < Constants.SPELL_TYPE__LIMIT; ++i) {
            data.spells.push(null);
        }

        for each (var spellNode :XML in xml.Spells.Spell) {
            type = XmlReader.getEnumAttr(spellNode, "type", Constants.SPELL_NAMES);
            var spellClass :Class =
                (type < Constants.CREATURE_SPELL_TYPE__LIMIT ? CreatureSpellData : SpellData);
            data.spells[type] = spellClass.fromXml(spellNode,
                (useDefaults ? defaults.spells[type] : null));
        }

        // read PlayerDisplayData
        for each (var playerDisplayXml :XML in xml.PlayerDisplayDatas.PlayerDisplay) {
            var name :String = XmlReader.getStringAttr(playerDisplayXml, "name");
            var inheritDisplayData :PlayerDisplayData;
            if (defaults != null) {
                inheritDisplayData = defaults.getPlayerDisplayData(name);
            }
            data.playerDisplayDatas.put(name,
                PlayerDisplayData.fromXml(playerDisplayXml, inheritDisplayData));
        }

        return data;
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
