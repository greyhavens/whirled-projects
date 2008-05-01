package popcraft.data {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.util.*;

import popcraft.*;
import popcraft.util.*;

public class GameData
{
    public var dayLength :Number;
    public var nightLength :Number;
    public var initialDayPhase :uint;

    public var spellDropTime :NumRange;
    public var spellDropScatter :NumRange;

    public var resources :Array = [];
    public var units :Array = [];
    public var spells :Array = [];
    public var baseLocs :Array = [];

    public function getBaseLocsForGameSize (numPlayers :uint) :Array
    {
        return (numPlayers - 1 < baseLocs.length ? baseLocs[numPlayers - 1] : []);
    }

    public function clone () :GameData
    {
        var theClone :GameData = new GameData();

        theClone.dayLength = dayLength;
        theClone.nightLength = nightLength;
        theClone.initialDayPhase = initialDayPhase;
        theClone.spellDropTime = spellDropTime.clone();
        theClone.spellDropScatter = spellDropScatter.clone();

        for each (var resData :ResourceData in resources) {
            theClone.resources.push(resData.clone());
        }

        for each (var unitData :UnitData in units) {
            theClone.units.push(unitData.clone());
        }

        for each (var spellData :SpellData in spells) {
            theClone.spells.push(spellData.clone());
        }

        for each (var gameSize :Array in baseLocs) {
            var gameSizeClone :Array = [];
            for each (var baseLoc :Vector2 in gameSize) {
                gameSizeClone.push(baseLoc.clone());
            }
            theClone.baseLocs.push(gameSizeClone);
        }

        return theClone;
    }

    public static function fromXml (xml :XML, inheritFrom :GameData = null) :GameData
    {
        var useDefaults :Boolean = (null != inheritFrom);

        var gameData :GameData = (useDefaults ? inheritFrom : new GameData());

        gameData.dayLength = XmlReader.getAttributeAsNumber(xml, "dayLength", (useDefaults ? gameData.dayLength : undefined));
        gameData.nightLength = XmlReader.getAttributeAsNumber(xml, "nightLength", (useDefaults ? gameData.nightLength : undefined));
        gameData.initialDayPhase = XmlReader.getAttributeAsEnum(xml, "initialDayPhase", Constants.DAY_PHASE_NAMES, (useDefaults ? gameData.initialDayPhase : undefined));

        var spellDropTimeMin :Number = XmlReader.getAttributeAsNumber(xml, "spellDropTimeMin", (useDefaults ? gameData.spellDropTime.min : undefined));
        var spellDropTimeMax :Number = XmlReader.getAttributeAsNumber(xml, "spellDropTimeMax", (useDefaults ? gameData.spellDropTime.max : undefined));
        gameData.spellDropTime = new NumRange(spellDropTimeMin, spellDropTimeMax, Rand.STREAM_GAME);

        var spellDropScatterMin :Number = XmlReader.getAttributeAsNumber(xml, "spellDropScatterMin", (useDefaults ? gameData.spellDropScatter.min : undefined));
        var spellDropScatterMax :Number = XmlReader.getAttributeAsNumber(xml, "spellDropScatterMax", (useDefaults ? gameData.spellDropScatter.max : undefined));
        gameData.spellDropScatter = new NumRange(spellDropScatterMin, spellDropScatterMax, Rand.STREAM_GAME);

        // init the resource data
        for (var i :int = gameData.resources.length; i < Constants.RESOURCE_NAMES.length; ++i) {
            gameData.resources.push(null);
        }

        for each (var resourceNode :XML in xml.Resources.Resource) {
            var type :uint = XmlReader.getAttributeAsEnum(resourceNode, "type", Constants.RESOURCE_NAMES);
            gameData.resources[type] = ResourceData.fromXml(resourceNode, (useDefaults ? inheritFrom.resources[type] : null));
        }

        // init the unit data
        for (i = gameData.units.length; i < Constants.UNIT_NAMES.length; ++i) {
            gameData.units.push(null);
        }

        for each (var unitNode :XML in xml.Units.Unit) {
            type = XmlReader.getAttributeAsEnum(unitNode, "type", Constants.UNIT_NAMES);
            gameData.units[type] = UnitData.fromXml(unitNode, (useDefaults ? inheritFrom.units[type] : null));
        }

        // init the spell data
        for (i = gameData.spells.length; i < Constants.SPELL_NAMES.length; ++i) {
            gameData.spells.push(null);
        }

        for each (var spellNode :XML in xml.Spells.Spell) {
            type = XmlReader.getAttributeAsEnum(spellNode, "type", Constants.SPELL_NAMES);
            gameData.spells[type] = SpellData.fromXml(spellNode, (useDefaults ? inheritFrom.spells[type] : null));
        }

        // read base locations
        for each (var gameSizeNode :XML in xml.BaseLocations.GameSize) {
            var numPlayers :int = XmlReader.getAttributeAsUint(gameSizeNode, "numPlayers");

            var baseLocArray :Array = [];

            for each (var baseLocNode :XML in gameSizeNode.BaseLocation) {
                var x :Number = XmlReader.getAttributeAsNumber(baseLocNode, "x");
                var y :Number = XmlReader.getAttributeAsNumber(baseLocNode, "y");
                baseLocArray.push(new Vector2(x, y));
            }

            for (i = gameData.baseLocs.length; i < numPlayers; ++i) {
                gameData.baseLocs.push(null);
            }

            gameData.baseLocs[numPlayers - 1] = baseLocArray;
        }

        return gameData;
    }

    public function generateUnitReport () :String
    {
        var report :String = "";

        for each (var srcUnit :UnitData in units) {

            if (srcUnit.name == "base") {
                continue;
            }

            report += srcUnit.name;

            var weapon :UnitWeaponData = srcUnit.weapon;

            var rangeMin :Number = weapon.damageRange.min;
            var rangeMax :Number = weapon.damageRange.max;
            var damageType :uint = weapon.damageType;

            report += "\nWeapon damage range: (" + rangeMin + ", " + rangeMax + ")";

            for each (var dstUnit :UnitData in units) {
                var dmgMin :Number = (null != dstUnit.armor ? dstUnit.armor.getDamage(damageType, rangeMin) : Number.NEGATIVE_INFINITY);
                var dmgMax :Number = (null != dstUnit.armor ? dstUnit.armor.getDamage(damageType, rangeMax) : Number.NEGATIVE_INFINITY);
                // dot == damage over time
                var dotMin :Number = dmgMin / weapon.cooldown;
                var dotMax :Number = dmgMax / weapon.cooldown;
                // ttk == time-to-kill
                var ttkMin :Number = dstUnit.maxHealth / dotMax;
                var ttkMax :Number = dstUnit.maxHealth / dotMin;
                var ttkAvg :Number = (ttkMin + ttkMax) / 2;

                report += "\nvs " + dstUnit.name + ": (" + dmgMin.toFixed(2) + ", " + dmgMax.toFixed(2) + ")";
                report += " DOT: (" + dotMin.toFixed(2) + "/s, " + dotMax.toFixed(2) + "/s)";
                report += " avg time-to-kill: " + ttkAvg.toFixed(2);
            }

            report += "\n\n";
        }

        return report;
    }
}

}
