package popcraft.battle {

import com.threerings.util.Assert;

import popcraft.*;
import popcraft.battle.geom.CollisionGrid;

public class UnitFactory
{
    public static function createUnit (unitType :uint, owningPlayerId :uint, collisionGrid :CollisionGrid) :Unit
    {
        var unit :Unit;

        switch (unitType) {
        case Constants.UNIT_TYPE_GRUNT:
            return new GruntCreatureUnit(owningPlayerId, collisionGrid);

        case Constants.UNIT_TYPE_HEAVY:
            return new HeavyCreatureUnit(owningPlayerId, collisionGrid);
        }
        
        Assert.fail("Unsupported unitType: " + unitType);
        return null;
    }
}

}
