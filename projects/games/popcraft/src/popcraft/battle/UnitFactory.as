package popcraft.battle {

import com.threerings.util.Assert;

import popcraft.*;

public class UnitFactory
{
    public static function createUnit (unitType :uint, owningPlayerId :uint) :Unit
    {
        var unit :Unit;

        switch (unitType) {
        case Constants.UNIT_TYPE_GRUNT:
            unit = new GruntCreatureUnit(owningPlayerId);
            break;

        case Constants.UNIT_TYPE_HEAVY:
            unit = new HeavyCreatureUnit(owningPlayerId);
            break;
            
        case Constants.UNIT_TYPE_SAPPER:
            unit = new SapperCreatureUnit(owningPlayerId);
            break;
            
        case Constants.UNIT_TYPE_BASE:
            unit = new PlayerBaseUnit(owningPlayerId);
            break;
            
        default:
            Assert.fail("Unsupported unitType: " + unitType);
            break;
        }
        
        if (unit is CreatureUnit) {
            var creature :CreatureUnit = (unit as CreatureUnit);
            var creatureView :CreatureUnitView = new CreatureUnitView(creature);
            
            GameMode.instance.addObject(creatureView, GameMode.instance.battleUnitDisplayParent);
            
        } else if (unit is PlayerBaseUnit) {
            var base :PlayerBaseUnit = (unit as PlayerBaseUnit);
            var baseView :PlayerBaseUnitView = new PlayerBaseUnitView(base);
            
            GameMode.instance.addObject(baseView, GameMode.instance.battleUnitDisplayParent);
        }
        
        GameMode.instance.netObjects.addObject(unit);
        
        return unit;
    }
}

}
