package popcraft.battle {

import popcraft.*;

public class UnitFactory
{
    public static function createUnit (unitType :uint, owningPlayerId :uint) :Unit
    {
        var unit :Unit;

        switch (unitType) {
        case Constants.UNIT_MELEE:
            unit = new Unit(owningPlayerId);
        }

        return unit;
    }
}

}
