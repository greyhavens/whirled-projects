package popcraft.battle {

import popcraft.*;

public class UnitFactory
{
    public static function createUnit (unitType :uint, owningPlayerId :uint) :Unit
    {
        /*var unit :Unit;

        switch (unitType) {
        case Constants.UNIT_TYPE_MELEE:
            unit = new Unit(owningPlayerId);
        }

        return unit;*/

        return new Unit(unitType, owningPlayerId);
    }
}

}
