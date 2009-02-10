package bloodbloom.client {

import bloodbloom.*;

public class PredatorCursor extends PlayerCursor
{
    public static function getAll () :Array
    {
        return GameCtx.netObjDb.getObjectsInGroup("PredatorCursor");
    }

    public function PredatorCursor ()
    {
        init(
            Constants.PREDATOR_SPEED_BASE,
            Constants.PREDATOR_SPEED_MIN,
            Constants.PREDATOR_SPEED_MAX);
    }

    override protected function update (dt :Number) :void
    {
        // speed decays over time
        offsetSpeedBonus(-Constants.PREDATOR_SPEED_DECREASE_PER_SECOND * dt);

        // update movement
        super.update(dt);

        // collide with cells
        var cell :Cell = Cell.getCellCollision(this);
        if (cell != null) {
            if (cell.type == Constants.CELL_RED) {
                // create a cell burst
                GameObjects.createCellBurst(cell);

            } else {
                // attach the white cell to us
                cell.destroySelf();
                if (++_whiteCellCount >= Constants.MAX_PREDATOR_WHITE_CELLS) {
                    GameCtx.gameMode.gameOver("Predator knocked out!");
                }

                dispatchEvent(new GameEvent(GameEvent.ATTACHED_CELL, cell));
            }
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return "PredatorCursor";
        default:    return super.getObjectGroup(groupNum - 1);
        }
    }

    public function get numWhiteCells () :int
    {
        return _whiteCellCount;
    }

    override public function clone (theClone :CollidableObj = null) :CollidableObj
    {
        var cursorClone :PredatorCursor = PredatorCursor(super.clone(theClone));

        cursorClone._whiteCellCount = _whiteCellCount;

        return cursorClone;
    }

    protected var _whiteCellCount :int;
}

}
