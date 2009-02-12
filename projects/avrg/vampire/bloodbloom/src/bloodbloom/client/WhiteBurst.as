package bloodbloom.client {

import bloodbloom.*;

import com.whirled.contrib.simplegame.tasks.*;

public class WhiteBurst extends CellBurst
{
    public function WhiteBurst ()
    {
        super(
            Constants.CELL_WHITE,
            Constants.WHITE_BURST_RADIUS_MIN,
            Constants.WHITE_BURST_RADIUS_MAX);
    }

    override protected function beginBurst () :void
    {
        addTask(ScaleTask.CreateEaseOut(
            this.targetScale,
            this.targetScale,
            Constants.BURST_EXPAND_TIME));

        addTask(new SerialTask(
            new TimedTask(Constants.BURST_COMPLETE_TIME),
            new SelfDestructTask()));
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        // When we collide with red cells, bonus cells, or RedBursts, we create new WhiteBursts
        var collided :CollidableObj = RedBurst.getRedBurstCollision(this);
        if (collided == null) {
            var cell :Cell = Cell.getCellCollision(this);
            if (cell != null && cell.state == Cell.STATE_NORMAL && !cell.isWhiteCell) {
                collided = cell;
            }
        }

        if (collided != null) {
            GameObjects.createWhiteBurst(collided);
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return GROUP_NAME;
        default:    return super.getObjectGroup(groupNum - 1);
        }
    }

    protected static const GROUP_NAME :String = "WhiteBurst";
}

}
