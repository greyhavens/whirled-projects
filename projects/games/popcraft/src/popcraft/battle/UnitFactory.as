package popcraft.battle {

import popcraft.*;

public class UnitFactory
{
    public static function createUnit (unitType :uint, owningPlayerId :uint) :Unit
    {
        /*var unit :Unit;

        switch (unitType) {
        case Constants.UNIT_TYPE_GRUNT:
            unit = new GruntCreatureUnit(owningPlayerId);
        }

        return unit;*/

        return new CreatureUnit(unitType, owningPlayerId);
    }
}

}
