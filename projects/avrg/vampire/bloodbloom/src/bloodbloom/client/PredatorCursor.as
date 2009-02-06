package bloodbloom.client {

import bloodbloom.*;

import com.threerings.flash.Vector2;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

public class PredatorCursor extends PlayerCursor
{
    public static function getAll () :Array
    {
        return GameCtx.gameMode.getObjectsInGroup("PredatorCursor");
    }

    public function PredatorCursor ()
    {
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

            } /*else {
                // attach the white cell to us
                var bm :Bitmap = ClientCtx.createCellBitmap(Constants.CELL_WHITE);
                var loc :Point = new Point(cell.x, cell.y);
                loc = GameCtx.cellLayer.localToGlobal(loc);
                loc = this.displayObject.globalToLocal(loc);
                loc.x -= bm.width * 0.5;
                loc.y -= bm.height * 0.5;
                bm.x = loc.x;
                bm.y = loc.y;
                _sprite.addChild(bm);
                _whiteCells.push(bm);
                cell.destroySelf();

                if (_whiteCells.length >= Constants.MAX_PREDATOR_WHITE_CELLS) {
                    GameCtx.gameMode.gameOver("Predator knocked out!");
                }
            }*/
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
        return _whiteCells.length;
    }

    protected var _sprite :Sprite;
    protected var _whiteCells :Array = [];
}

}
