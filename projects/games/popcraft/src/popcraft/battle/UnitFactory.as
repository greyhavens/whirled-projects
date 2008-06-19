package popcraft.battle {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.audio.*;

import popcraft.*;
import popcraft.battle.view.*;

public class UnitFactory
{
    public static function createCreature (unitType :int, owningPlayerIndex :int) :void
    {
        // sanity check. dead players create no monsters.
        if (!PlayerInfo(GameContext.playerInfos[owningPlayerIndex]).isAlive) {
            return;
        }

        var creature :CreatureUnit;

        switch (unitType) {
        case Constants.UNIT_TYPE_GRUNT:
            creature = new GruntCreatureUnit(owningPlayerIndex);
            break;

        case Constants.UNIT_TYPE_HEAVY:
            creature = new HeavyCreatureUnit(owningPlayerIndex);
            break;

        case Constants.UNIT_TYPE_SAPPER:
            creature = new SapperCreatureUnit(owningPlayerIndex);
            break;

        case Constants.UNIT_TYPE_COLOSSUS:
            creature = new ColossusCreatureUnit(owningPlayerIndex);
            break;

        case Constants.UNIT_TYPE_COURIER:
            creature = new CourierCreatureUnit(owningPlayerIndex);
            break;

        case Constants.UNIT_TYPE_BOSS:
            creature = new BossCreatureUnit(owningPlayerIndex);
            break;

        default:
            Assert.fail("Unsupported unitType: " + unitType);
            break;
        }

        // unit views may depend on the unit already having been added to an ObjectDB,
        // so do that before creating a unit view
        GameContext.netObjects.addObject(creature);

        var creatureView :CreatureUnitView;
        switch (unitType) {
        case Constants.UNIT_TYPE_COURIER:
            creatureView = new CourierCreatureUnitView(creature as CourierCreatureUnit);
            break;

        default:
            creatureView = new CreatureUnitView(creature);
            break;
        }

        GameContext.gameMode.addObject(creatureView, GameContext.battleBoardView.unitViewParent);

        // play a sound
        GameContext.playGameSound("sfx_create_" + Constants.CREATURE_UNIT_NAMES[unitType]);
    }

    public static function createBaseUnit (owningPlayerIndex :int, maxHealthOverride :int = 0, startingHealthOverride :int = 0) :PlayerBaseUnit
    {
        var base :PlayerBaseUnit = new PlayerBaseUnit(owningPlayerIndex, maxHealthOverride, startingHealthOverride);

        GameContext.netObjects.addObject(base);

        var baseView :PlayerBaseUnitView = new PlayerBaseUnitView(base);
        GameContext.gameMode.addObject(baseView, GameContext.battleBoardView.unitViewParent);

        return base;
    }
}

}
