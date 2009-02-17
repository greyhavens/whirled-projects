package vampire.feeding.client {

import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.tasks.*;

import vampire.feeding.*;

public class RedBurst extends CellBurst
{
    public static function getRedBurstCollision (obj :CollidableObj) :RedBurst
    {
        // returns the first burst that collides with the given object
        var bursts :Array = GameCtx.gameMode.getObjectRefsInGroup(GROUP_NAME);
        for each (var ref :SimObjectRef in bursts) {
            var burst :RedBurst = ref.object as RedBurst;
            if (burst != null && burst.collidesWith(obj)) {
                return burst;
            }
        }

        return null;
    }

    public function RedBurst (fromCell :Cell, sequence :BurstSequence)
    {
        super(fromCell.type, Constants.RED_BURST_RADIUS_MIN, Constants.RED_BURST_RADIUS_MAX);
        _sequence = sequence;
        _multiplier = fromCell.multiplier;
    }

    override protected function beginBurst () :void
    {
        addTask(ScaleTask.CreateEaseOut(
            this.targetScale,
            this.targetScale,
            Constants.BURST_EXPAND_TIME));

        addTask(new SerialTask(
            new TimedTask(Constants.BURST_COMPLETE_TIME),
            new FunctionTask(function () :void {
                _burstCompleted = true;
            }),
            new SelfDestructTask()));

        if (_sequence == null) {
            _sequence = new BurstSequence();
            _sequence.x = x;
            _sequence.y = y;
            GameCtx.gameMode.addObject(_sequence, GameCtx.effectLayer);
        }
        _sequence.addCellBurst(this);

        ClientCtx.audio.playSoundNamed("sfx_red_burst");
    }

    override protected function removedFromDB () :void
    {
        if (!_burstCompleted) {
            _sequence.removeCellBurst(this);
        }
    }

    public function get multiplier () :int
    {
        return _multiplier;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        // We're bursting. When we collide with red cells or RedBursts, we create new WhiteBursts;
        var cell :Cell = Cell.getCellCollision(this);
        if (cell != null && !cell.isWhiteCell && cell.state == Cell.STATE_NORMAL) {
            GameObjects.createRedBurst(cell, _sequence);
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return GROUP_NAME;
        default:    return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _sequence :BurstSequence;
    protected var _multiplier :int = 1;
    protected var _burstCompleted :Boolean;

    protected static const GROUP_NAME :String = "RedBurst";
}

}
