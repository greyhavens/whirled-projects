package popcraft.battle {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.audio.*;

import flash.events.EventDispatcher;

import popcraft.*;
import popcraft.game.*;
import popcraft.battle.view.*;

public class UnitFactory extends EventDispatcher
{
    public function createCreature (unitType :int, owningPlayerIndex :int) :void
    {
        // sanity check. dead players create no monsters.
        if (!PlayerInfo(GameCtx.playerInfos[owningPlayerIndex]).isAlive) {
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
        GameCtx.netObjects.addObject(creature);

        var creatureView :CreatureUnitView;
        switch (unitType) {
        case Constants.UNIT_TYPE_COURIER:
            creatureView = new CourierCreatureUnitView(creature as CourierCreatureUnit);
            break;

        default:
            creatureView = new CreatureUnitView(creature);
            break;
        }

        GameCtx.gameMode.addObject(creatureView, GameCtx.battleBoardView.unitViewParent);

        // play a sound
        GameCtx.playGameSound("sfx_create_" + Constants.CREATURE_UNIT_NAMES[unitType]);

        dispatchEvent(new UnitCreatedEvent(unitType, owningPlayerIndex));
    }

    public function createWorkshop (owningPlayerInfo :PlayerInfo) :WorkshopView
    {
        var workshop :WorkshopUnit = new WorkshopUnit(owningPlayerInfo);
        GameCtx.netObjects.addObject(workshop);

        var workshopView :WorkshopView = new WorkshopView(workshop);
        GameCtx.gameMode.addObject(workshopView, GameCtx.battleBoardView.unitViewParent);

        dispatchEvent(new UnitCreatedEvent(Constants.UNIT_TYPE_WORKSHOP,
            owningPlayerInfo.playerIndex));

        return workshopView;
    }
}

}
