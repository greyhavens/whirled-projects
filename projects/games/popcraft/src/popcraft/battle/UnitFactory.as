package popcraft.battle {

import popcraft.*;

public class UnitFactory
{
    public static function createUnit (unitType :uint, owningPlayerId :uint) :Unit
    {
        var unit :Unit;

        switch (unitType) {
        case Constants.UNIT_TYPE_GRUNT:
            return new GruntCreatureUnit(owningPlayerId);

        case Constants.UNIT_TYPE_HEAVY:
            return new HeavyCreatureUnit(owningPlayerId);

        default:
            return new CreatureUnit(unitType, owningPlayerId);
        }
    }
}

}
