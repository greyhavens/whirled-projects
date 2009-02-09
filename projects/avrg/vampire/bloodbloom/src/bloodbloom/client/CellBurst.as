package bloodbloom.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Collision;

import bloodbloom.*;

public class CellBurst extends CollidableObj
{
    public static const STATE_BURST :int = 0;
    public static const STATE_UNBURST :int = 1;

    public function CellBurst (x :Number, y :Number, sequence :BurstSequence = null)
    {
        _radius = Constants.BURST_RADIUS_MIN;

        _sequence = sequence;
        if (_sequence == null) {
            _sequence = new BurstSequence();
            _sequence.x = x;
            _sequence.y = y;
            GameCtx.gameMode.addObject(_sequence, GameCtx.effectLayer);
        }

        this.x = x;
        this.y = y;
    }

    override protected function addedToDB () :void
    {
        beginBurst();
    }

    protected function beginBurst () :void
    {
        removeAllTasks();

        var thisBurst :CellBurst = this;

        var targetScale :Number = Constants.BURST_RADIUS_MAX / Constants.BURST_RADIUS_MIN;
        addTask(ScaleTask.CreateEaseOut(targetScale, targetScale, Constants.BURST_EXPAND_TIME));
        addTask(new SerialTask(
            new TimedTask(Constants.BURST_COMPLETE_TIME),
            new SelfDestructTask()));

        _sequence.addCellBurst(this);
        _state = STATE_BURST;
    }

    protected function beginUnburst () :void
    {
        removeAllTasks();

        var thisBurst :CellBurst = this;

        addTask(new SerialTask(
            ScaleTask.CreateEaseIn(1, 1, Constants.BURST_CONTRACT_TIME),
            new FunctionTask(
                function () :void {
                    var newCell :Cell = GameObjects.createCell(Constants.CELL_RED, false);
                    newCell.x = thisBurst.x;
                    newCell.y = thisBurst.y;
                }),
            new SelfDestructTask()));

        _sequence.removeCellBurst(this);
        _state = STATE_UNBURST;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_state == STATE_BURST) {
            // We're bursting. When we collide with red cells, we create new CellBursts;
            // When we collide with white cells, we unburst.
            var cell :Cell = Cell.getCellCollision(this);
            if (cell != null) {
                if (cell.isRedCell) {
                    GameObjects.createCellBurst(cell, _sequence);
                } else {
                    beginUnburst();
                }
            }

            if (collidesWith(GameCtx.prey)) {
                GameCtx.gameMode.gameOver("Prey hit a blood burst!");
            }

        } else if (_state == STATE_UNBURST) {
            // We're unbursting. Collide with other CellBursts and contract them back into cells.
            var bursts :Array = GameCtx.netObjDb.getObjectRefsInGroup("CellBurst");
            for each (var burstRef :SimObjectRef in bursts) {
                var burst :CellBurst = burstRef.object as CellBurst;
                if (burst != null && burst != this && burst._state == STATE_BURST) {
                    if (collidesWith(burst)) {
                        burst.beginUnburst();
                        break;
                    }
                }
            }
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        if (groupNum == 0) {
            return "CellBurst";
        } else {
            return super.getObjectGroup(groupNum - 1);
        }
    }

    public function get state () :int
    {
        return _state;
    }

    protected var _state :int;
    protected var _sequence :BurstSequence;
}

}
