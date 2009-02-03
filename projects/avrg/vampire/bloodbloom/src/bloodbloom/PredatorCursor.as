package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

public class PredatorCursor extends SceneObject
{
    public function PredatorCursor (controlledLocally :Boolean)
    {
        _controlledLocally = controlledLocally;
        _sprite = new Sprite();
        var bitmap :Bitmap = ClientCtx.instantiateBitmap("predator_cursor");
        bitmap.x = -bitmap.width * 0.5;
        bitmap.y = -bitmap.height * 0.5;
        _sprite.addChild(bitmap);
    }

    override protected function update (dt :Number) :void
    {
        if (_controlledLocally) {
            updateMovement(dt);
        }
    }

    protected function updateMovement (dt :Number) :void
    {
        var targetLoc :Vector2 = new Vector2(
            ClientCtx.gameMode.modeSprite.mouseX,
            ClientCtx.gameMode.modeSprite.mouseY);

        var oldLoc :Vector2 = new Vector2(this.x, this.y);

        if (oldLoc.similar(targetLoc, 0.5)) {
            return;
        }

        var newLoc :Vector2 = targetLoc.subtract(oldLoc);
        var targetDist :Number = newLoc.normalizeLocalAndGetLength();
        var moveDist :Number = this.speed * dt;
        newLoc.scaleLocal(Math.min(targetDist, moveDist));
        newLoc.addLocal(oldLoc);

        // clamp to game boundaries
        newLoc = ClientCtx.clampLoc(newLoc);

        // collide with cells
        var cell :Cell = Cell.getCellCollision(newLoc, Constants.CURSOR_RADIUS);
        if (cell != null) {
            if (cell.type == Constants.CELL_RED) {
                // create a cell burst
                CellBurst.createFromCell(cell);
            } else {
                // attach the white cell to us
            }
        }

        // move!
        this.x = newLoc.x;
        this.y = newLoc.y;

        // rotate the bitmap. 0 degrees == straight up
        var angle :Number = newLoc.subtract(oldLoc).angle * (180 / Math.PI);
        this.rotation = angle + 90;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function get speed () :Number
    {
        return Constants.PREDATOR_SPEED_BASE;
    }

    protected var _controlledLocally :Boolean;
    protected var _sprite :Sprite;
    protected var _whiteCells :Array = [];

    protected var _lastArtery :int = -1;
}

}
