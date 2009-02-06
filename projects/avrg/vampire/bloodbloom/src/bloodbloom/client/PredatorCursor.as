package bloodbloom.client {

import bloodbloom.*;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;

public class PredatorCursor extends PlayerCursor
{
    public static function getAll () :Array
    {
        return GameCtx.gameMode.getObjectsInGroup("PredatorCursor");
    }

    override protected function update (dt :Number) :void
    {
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

    override protected function get speed () :Number
    {
        return Constants.PREDATOR_SPEED_BASE;
    }

    public function get numWhiteCells () :int
    {
        return _whiteCellCount;
    }

    protected var _sprite :Sprite;
    protected var _whiteCellCount :int;
}

}
