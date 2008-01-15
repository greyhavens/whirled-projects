package popcraft.battle.ai {
    import popcraft.battle.Unit;


public class AttackUnitTask extends AITaskBase
{
    public function AttackUnitTask (unitId :uint)
    {
        _unitId = unitId;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);

        var unit :CreatureUnit = (obj as CreatureUnit);
        var enemy :Unit = (GameMode.instance.netObjects.getObject(_unitId) as Unit);

        // is the enemy dead? does it still hold our interest?
        if (null == enemy || !unit.isUnitInInterestRange(enemy)) {
            return true;
        }

        // the enemy is still alive. Can we attack?
        if (unit.canAttackUnit(enemy, unit.unitData.attack)) {
            unit.removeNamedTasks("move");
            unit.sendAttack(enemy, unit.unitData.attack);
        } else {
            // should we try to get closer to the enemy?
            var attackLoc :Vector2 = unit.findNearestAttackLocation(enemy, unit.unitData.attack);
            unit.moveTo(attackLoc.x, attackLoc.y);
        }

        return false;
    }

    override public function clone () :ObjectTask
    {
        return new AttackUnitTask(_unitId);
    }

    protected var _unitId :uint;

}

}
