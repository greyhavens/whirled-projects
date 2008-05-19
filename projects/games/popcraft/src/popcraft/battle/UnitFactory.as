package popcraft.battle {

import com.threerings.util.Assert;

import com.whirled.contrib.simplegame.audio.*;

import popcraft.*;
import popcraft.battle.view.*;

public class UnitFactory
{
    public static function createCreature (unitType :uint, owningPlayerId :uint) :CreatureUnit
    {
        var creature :CreatureUnit;

        switch (unitType) {
        case Constants.UNIT_TYPE_GRUNT:
            creature = new GruntCreatureUnit(owningPlayerId);
            break;

        case Constants.UNIT_TYPE_HEAVY:
            creature = new HeavyCreatureUnit(owningPlayerId);
            break;

        case Constants.UNIT_TYPE_SAPPER:
            creature = new SapperCreatureUnit(owningPlayerId);
            break;

        case Constants.UNIT_TYPE_COLOSSUS:
            creature = new ColossusCreatureUnit(owningPlayerId);
            break;

        case Constants.UNIT_TYPE_COURIER:
            creature = new CourierCreatureUnit(owningPlayerId);
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
        AudioManager.instance.playSoundNamed("sfx_create_" + Constants.CREATURE_UNIT_NAMES[unitType]);

        return creature;
    }

    public static function createBaseUnit (owningPlayerId :int, maxHealthOverride :int = 0, startingHealthOverride :int = 0) :PlayerBaseUnit
    {
        var base :PlayerBaseUnit = new PlayerBaseUnit(owningPlayerId, maxHealthOverride, startingHealthOverride);

        GameContext.netObjects.addObject(base);

        var baseView :PlayerBaseUnitView = new PlayerBaseUnitView(base);
        GameContext.gameMode.addObject(baseView, GameContext.battleBoardView.unitViewParent);

        return base;
    }
}

}
