package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;

import flash.geom.Point;

import popcraft.battle.*;
import popcraft.util.*;

public class Constants
{
    public static const SCREEN_DIMS :Vector2 = new Vector2(700, 500);

    /* Debug options */
    public static const DEBUG_DRAW_STATS :Boolean = true;
    public static const DEBUG_CHECKSUM_STATE :int = 0;
    public static const DEBUG_ALLOW_CHEATS :Boolean = true;
    public static const DEBUG_DRAW_UNIT_DATA_CIRCLES :Boolean = false;
    public static const DEBUG_DRAW_AOE_ATTACK_RADIUS :Boolean = false;
    public static const DEBUG_DISABLE_MOVEMENT_SMOOTHING :Boolean = false;
    public static const DEBUG_DISABLE_DIURNAL_CYCLE :Boolean = false;
    public static const DEBUG_LOAD_LEVELS_FROM_DISK :Boolean = true;

    /* Screen layout */
    public static const BATTLE_BOARD_LOC :Point = new Point(0, 0);

    public static const RESOURCE_DISPLAY_LOC :Point = new Point(350, 380);
    public static const PUZZLE_BOARD_LOC :Point = new Point(10, 378);
    public static const RESOURCE_POPUP_LOC :Point = new Point(275, 425);
    public static const DIURNAL_METER_LOC :Point = new Point(530, 425);
    public static const UNIT_QUEUE_LOC :Point = new Point(530, 400);

    public static const FIRST_UNIT_BUTTON_LOC :Point = new Point(350, 400);

    public static const PLAYER_COLORS :Array = [
       uint(0xFFFF0000),
       uint(0xFF9FBCFF),
       uint(0xFF51FF7E),
       uint(0xFFFFE75F)
    ];

    /* Puzzle stuff */
    public static const MIN_GROUP_SIZE :int = 1; // no min group size right now

    public static const PUZZLE_HEIGHT :int = 110;

    public static const PUZZLE_COLS :int = 12;
    public static const PUZZLE_ROWS :int = 5;

    public static const PUZZLE_TILE_SIZE :int = int(PUZZLE_HEIGHT / PUZZLE_ROWS);

    public static const CLEAR_VALUE_TABLE :IntValueTable =
        new IntValueTable( [-20, -10, 10, 10 ] );
             // group size:   1,   2,  3,  4+ = 20, 30, 40, ...

    /* Battle stuff */
    public static const BATTLE_WIDTH :int = 700;
    public static const BATTLE_HEIGHT :int = 372;

    public static const DAY_LENGTH :Number = 30;
    public static const NIGHT_LENGTH :Number = 120;

    /* Damage types */
    public static const DAMAGE_TYPE_CRUSHING :uint = 0;
    public static const DAMAGE_TYPE_PIERCING :uint = 1;
    public static const DAMAGE_TYPE_EXPLOSION :uint = 2;
    public static const DAMAGE_TYPE_BASE :uint = 3; // bases damage units that attack them

    public static const DAMAGE_TYPE_NAMES :Array = [ "crushing", "piercing", "explosion", "base" ];

    /* Resource types */

    // wow, I miss enums
    public static const RESOURCE_WHITE :uint = 0;
    public static const RESOURCE_RED :uint = 1;
    public static const RESOURCE_BLUE :uint = 2;
    public static const RESOURCE_YELLOW :uint = 3;
    public static const RESOURCE__LIMIT :uint = 4;

    public static const RESOURCE_TYPES :Array = [
        new ResourceData("flesh", 0xE8E7E5, 1),
        new ResourceData("blood", 0xCC0000, 1),
        new ResourceData("energy", 0x3D7078, 0.5),
        new ResourceData("artifice", 0xFFD858, 0.5)
    ];

    public static const RESOURCE_NAMES :Array = [ "white", "red", "yellow", "blue" ];

    public static function getResource (type :uint) :ResourceData {
        Assert.isTrue(type < RESOURCE_TYPES.length);
        return (RESOURCE_TYPES[type] as ResourceData);
    }

    /* Spells */
    public static const SPELL_TYPE_BLOODLUST :uint = 0;
    public static const SPELL_TYPE_RIGORMORTIS :uint = 1;

    public static const SPELL_TYPE__LIMIT :uint = 2;

    protected static const BLOODLUST_SPELL :UnitSpellData = UnitSpellBuilder.create()
        .type(SPELL_TYPE_BLOODLUST)
        .displayName("bloodlust")
        .expireTime(45)
        .speedScaleOffset(0.5)  // move 50% faster
        .damageScaleOffset(0.3) // take 30% more damage
        .spell;

    protected static const RIGOR_MORTIS_SPELL :UnitSpellData = UnitSpellBuilder.create()
        .type(SPELL_TYPE_RIGORMORTIS)
        .displayName("rigormortis")
        .expireTime(45)
        .damageScaleOffset(-0.4)    // take 40% less damage
        .spell;

    public static const UNIT_SPELLS :Array = [ BLOODLUST_SPELL, RIGOR_MORTIS_SPELL ];

    public static const SPELL_NAMES :Array = [ "bloodlust", "rigormortis" ];

    /* Units */

    public static const UNIT_GRID_CELL_SIZE :int = 40;

    public static const UNIT_TYPE_GRUNT :uint = 0;
    public static const UNIT_TYPE_HEAVY :uint = 1;
    public static const UNIT_TYPE_SAPPER :uint = 2;
    public static const UNIT_TYPE_COLOSSUS :uint = 3;

    public static const UNIT_TYPE__CREATURE_LIMIT :uint = 4;

    public static const UNIT_TYPE_BASE :uint = UNIT_TYPE__CREATURE_LIMIT;

    public static const UNIT_NAMES :Array = [ "grunt", "heavy", "sapper", "colossus", "base" ];

    protected static const GRUNT_WEAPON :UnitWeaponData = UnitWeaponBuilder.create()
        .damageType(DAMAGE_TYPE_CRUSHING)
        .damageRange(10, 10)
        .cooldown(1)
        .maxAttackDistance(35)
        .weapon;

    protected static const HEAVY_RANGED_WEAPON :UnitWeaponData = UnitWeaponBuilder.create()
        .isRanged(true)
        .damageType(DAMAGE_TYPE_PIERCING)
        .damageRange(5, 10)
        .cooldown(0.75)
        .maxAttackDistance(200)
        .missileSpeed(300)
        .weapon;

    protected static const SAPPER_EXPLODE_WEAPON :UnitWeaponData = UnitWeaponBuilder.create()
        .isAOE(true)
        .damageType(DAMAGE_TYPE_EXPLOSION)
        .damageRange(70, 70)
        .aoeRadius(75)
        .aoeAnimationName("attack_N")
        .aoeDamageFriendlies(false)
        .cooldown(1)
        .weapon;

    protected static const COLOSSUS_WEAPON :UnitWeaponData = UnitWeaponBuilder.create()
        .damageType(DAMAGE_TYPE_CRUSHING)
        .damageRange(80, 80)
        .maxAttackDistance(50)
        .cooldown(2)
        .weapon;

    protected static const BASE_WEAPON :UnitWeaponData = UnitWeaponBuilder.create()
        .damageType(DAMAGE_TYPE_BASE)
        .damageRange(20, 20)
        .cooldown(0)
        .maxAttackDistance(1000)
        .weapon;

    protected static const GRUNT_DATA :UnitData = UnitDataBuilder.create()
        .name("grunt")
        .displayName("Madame")
        .description("MADAME: Melee unit. Strong against the Handy Man. Susceptible to attacks from the Dog-boy.")
        .resourceCosts([40, 0, 15, 0])
        .baseMoveSpeed(35)
        .maxHealth(100)
        .armor(new UnitArmorData([0.7, 0.3, 1, 0.8]))
        .weapon(GRUNT_WEAPON)
        .collisionRadius(15)
        .detectRadius(60)
        .loseInterestRadius(180)
        .unitData;

    protected static const HEAVY_DATA :UnitData = UnitDataBuilder.create()
        .name("heavy")
        .displayName("Handy Man")
        .description("HANDY MAN: Ranged tower unit. Useful for deflecting incoming Dog-boys. Watch out for Madames.")
        .resourceCosts([0, 30, 0, 15])
        .baseMoveSpeed(50)
        .maxHealth(100)
        .armor(new UnitArmorData([1, 1, 1, 1]))
        .weapon(HEAVY_RANGED_WEAPON)
        .collisionRadius(15)
        .detectRadius(200)
        .loseInterestRadius(180)
        .unitData;

    protected static const SAPPER_DATA :UnitData = UnitDataBuilder.create()
        .name("sapper")
        .displayName("Dog-boy")
        .description("DOG-BOY: Explosive unit. Self-destructs to deal heavy damage to units in its vicinity. Useful for storming the enemy's base, but watch out for Handy Men!")
        .resourceCosts([0, 0, 25, 25])
        .baseMoveSpeed(35)
        .maxHealth(70)
        .armor(new UnitArmorData([1, 1, 1, 1]))
        .weapon(SAPPER_EXPLODE_WEAPON)
        .collisionRadius(15)
        .detectRadius(200)
        .loseInterestRadius(180)
        .unitData;

    protected static const COLOSSUS_DATA :UnitData = UnitDataBuilder.create()
        .name("colossus")
        .displayName("Flesh Colossus")
        .description("FLESH COLOSSUS: A massive pile of discarded flesh. The Colossus' powerful attack is dangerous to everybody, but it will slow down when swarmed by enemies.")
        .resourceCosts([250, 250, 0, 0])
        .baseMoveSpeed(25)
        .maxHealth(100)
        .armor(new UnitArmorData([0.1, 0.07, 0.1, 1]))
        .weapon(COLOSSUS_WEAPON)
        .collisionRadius(30)
        .detectRadius(COLOSSUS_WEAPON.maxAttackDistance) // only detect enemies in our attack range
        .unitData;

    protected static const BASE_DATA :UnitData = UnitDataBuilder.create()
        .name("base")
        .maxHealth(100)
        .armor(new UnitArmorData([0.05, 0.1, 0.1, 1]))
        .weapon(BASE_WEAPON)
        .collisionRadius(20)
        .unitData;

    // non-creature units must come after creature units
    public static const UNIT_DATA :Array = [ GRUNT_DATA, HEAVY_DATA, SAPPER_DATA, COLOSSUS_DATA, BASE_DATA ];

    public static const CREATURE_UNIT_NAMES :Array = [ "grunt", "heavy", "sapper", "colossus" ];

    public static function getPlayerBaseLocations (numPlayers :uint) :Array // of Vector2s
    {
        // return an array of Vector2 pairs - for each player, a base loc and an initial waypoint loc

        switch (numPlayers) {
        case 1:
            return [ new Vector2(50, 315) ]; // we don't have 1-player games except during development
            break;

        case 2:
            return [
                new Vector2(50, 315),   // bottom left
                new Vector2(652, 85),   // top right
             ];
             break;

        case 3:
            return [
                new Vector2(50, 85),       // top left
                new Vector2(50, 315),     // bottom left
                new Vector2(652, 175),    // middle right
            ];
            break;

        case 4:
            return [
                new Vector2(50, 85),    // top left
                new Vector2(50, 315),   // bottom left
                new Vector2(652, 85),   // top right
                new Vector2(652, 315),  // bottom right
            ];
            break;

        default:
            return [];
            break;
        }
    }

    public static function generateUnitReport () :String
    {
        var report :String = "";

        for each (var srcUnit :UnitData in Constants.UNIT_DATA) {

            if (srcUnit.name == "base") {
                continue;
            }

            report += srcUnit.name;

            var weapon :UnitWeaponData = srcUnit.weapon;

            var rangeMin :Number = weapon.damageRange.min;
            var rangeMax :Number = weapon.damageRange.max;
            var damageType :uint = weapon.damageType;

            report += "\nWeapon damage range: (" + rangeMin + ", " + rangeMax + ")";

            for each (var dstUnit :UnitData in Constants.UNIT_DATA) {
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
