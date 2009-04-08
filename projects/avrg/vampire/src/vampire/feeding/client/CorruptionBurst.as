package vampire.feeding.client {

import com.whirled.contrib.simplegame.tasks.*;

import vampire.feeding.*;
import vampire.server.Trophies;

public class CorruptionBurst extends CellBurst
{
    public function CorruptionBurst (isBlackBurst :Boolean, cellWasAttachedToCursor :Boolean,
                                     multiplier :int, sequence :BurstSequence)
    {
        super(
            isBlackBurst ? Constants.BURST_BLACK : Constants.BURST_WHITE,
            isBlackBurst ? Constants.BLACK_BURST_RADIUS_MIN : Constants.WHITE_BURST_RADIUS_MIN,
            isBlackBurst ? Constants.BLACK_BURST_RADIUS_MAX : Constants.WHITE_BURST_RADIUS_MAX,
            multiplier,
            sequence);

        _cellWasAttachedToCursor = cellWasAttachedToCursor;
    }

    override protected function beginBurst () :void
    {
        super.beginBurst();

        addTask(ScaleTask.CreateEaseOut(
            this.targetScale,
            this.targetScale,
            Constants.BURST_EXPAND_TIME));

        addTask(new SerialTask(
            new TimedTask(Constants.BURST_COMPLETE_TIME),
            new FunctionTask(function () :void {
                // Detonate a white cell you're carrying without corrupting red cells
                if (_cellWasAttachedToCursor && !_corruptionSpread) {
                    ClientCtx.awardTrophy(Trophies.NECESSARY_EVIL);
                }
            }),
            new SelfDestructTask()));

        ClientCtx.audio.playSoundNamed("sfx_white_burst");
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        // When we collide with red cells, bonus cells, or RedBursts, we create new CorruptionBursts
        var collided :CollidableObj = RedBurst.getRedBurstCollision(this);
        if (collided == null) {
            var cell :Cell = Cell.getCellCollision(this);
            if (cell != null && cell.state == Cell.STATE_NORMAL) {
                collided = cell;
            }
        }

        if (collided != null) {
            GameObjects.createCorruptionBurst(collided, _sequence);
            _corruptionSpread = true;
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return GROUP_NAME;
        default:    return super.getObjectGroup(groupNum - 1);
        }
    }

    // We track whether the cell that caused the burst was attached to the player cursor
    // in order to award the "Necessary Evil" trophy
    protected var _cellWasAttachedToCursor :Boolean;
    protected var _corruptionSpread :Boolean;

    protected static const GROUP_NAME :String = "WhiteBurst";
}

}
