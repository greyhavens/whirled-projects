package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Sappers are suicide-bombers. They deal heavy
 * damage to enemies and bases.
 */
public class SapperCreatureUnit extends CreatureUnit
{
    public function SapperCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_SAPPER, owningPlayerId);

        _sapperAI = new SapperAI(this, this.findEnemyBaseToAttack());
    }

    override protected function get aiRoot () :AITask
    {
        return _sapperAI;
    }

    override public function sendAttack (targetUnitOrLoc :*, weapon :UnitWeapon) :void
    {
        // when the sapper attacks, he self-destructs
        super.sendAttack(targetUnitOrLoc, weapon);

        this.die();
    }

    override public function receiveAttack (attack :UnitAttack) :void
    {
        // if the sapper is killed by an attack, he explodes

        var wasDead :Boolean = _isDead;
        super.receiveAttack(attack);

        // prevent infinite recursion - don't explode if we're already dead
        if (!wasDead && _isDead) {
            this.sendAttack(this.unitLoc, _unitData.weapons[0]);
        }
    }

    protected var _sapperAI :SapperAI;
}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;

/**
 * Goals:
 * (Priority 1) Attack groups of approaching enemies.
 * (Priority 1) Attack enemy base
 */
class SapperAI extends AITaskTree
{
    public function SapperAI (unit :SapperCreatureUnit, targetBaseRef :SimObjectRef)
    {
        _unit = unit;
        _targetBaseRef = targetBaseRef;

        this.beginAttackBase();
        this.scanForEnemyGroups();
    }

    protected function beginAttackBase () :void
    {
        this.addSubtask(new AttackUnitTask(_targetBaseRef, true, -1));
    }

    protected function scanForEnemyGroups () :void
    {
        var taskSequence :AITaskSequence = new AITaskSequence(true);
        taskSequence.addSequencedTask(new AITimerTask(SCAN_FOR_ENEMIES_DELAY));
        taskSequence.addSequencedTask(new ScanForEnemyGroupTask(SCAN_FOR_ENEMIES_TASK_NAME, 2));

        this.addSubtask(taskSequence);
    }

    override public function get name () :String
    {
        return "SapperAI";
    }

    protected var _unit :SapperCreatureUnit;
    protected var _targetBaseRef :SimObjectRef;

    protected static const SCAN_FOR_ENEMIES_DELAY :Number = 1;
    protected static const SCAN_FOR_ENEMIES_TASK_NAME :String = "ScanForEnemies";
}

class ScanForEnemyGroupTask extends AITask
{
    public function ScanForEnemyGroupTask (name :String, groupSize :int)
    {
        _name = name;
    }

    override public function get name () :String
    {
        return name;
    }

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        return AITaskStatus.COMPLETE;
    }

    protected var _name :String;
}
