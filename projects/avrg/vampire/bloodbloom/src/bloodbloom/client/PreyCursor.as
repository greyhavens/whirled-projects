package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

public class PreyCursor extends PlayerCursor
{
    public function PreyCursor ()
    {
        updateArteryHilite();
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        // collide with cells
        /*var cell :Cell = Cell.getCellCollision(newLoc, Constants.CURSOR_RADIUS);
        if (cell != null) {
            var bm :Bitmap = ClientCtx.createCellBitmap(cell.type);
            var loc :Point = new Point(cell.x, cell.y);
            loc = GameCtx.cellLayer.localToGlobal(loc);
            loc = this.displayObject.globalToLocal(loc);
            loc.x -= bm.width * 0.5;
            loc.y -= bm.height * 0.5;
            bm.x = loc.x;
            bm.y = loc.y;
            _sprite.addChild(bm);

            if (cell.type == Constants.CELL_RED) {
                _redCells.push(bm);
            } else {
                _whiteCells.push(bm);
            }

            cell.destroySelf();
        }

        // collide with the arteries
        var crossedCtr :Boolean =
            (newLoc.x >= Constants.GAME_CTR.x && oldLoc.x < Constants.GAME_CTR.x) ||
            (newLoc.x <= Constants.GAME_CTR.x && oldLoc.x > Constants.GAME_CTR.x);

        var artery :int = -1;
        if (crossedCtr) {
            if (newLoc.y < Constants.GAME_CTR.y && canCollideArtery(Constants.ARTERY_TOP)) {
                artery = Constants.ARTERY_TOP;
            } else if (newLoc.y >= Constants.GAME_CTR.y && canCollideArtery(Constants.ARTERY_BOTTOM)) {
                artery = Constants.ARTERY_BOTTOM;
            }

            if (artery != -1) {
                collideArtery(artery);
            } else {
                // we're prevented from crossing the artery
                newLoc.x = (newLoc.x >= Constants.GAME_CTR.x ?
                            Constants.GAME_CTR.x - 1 : Constants.GAME_CTR.x + 1);
            }
        }*/
    }

    override protected function get speed () :Number
    {
        var speed :Number = Math.max(
            Constants.PREY_SPEED_BASE + (Constants.PREY_SPEED_CELL_OFFSET * _redCells.length),
            Constants.PREY_SPEED_MIN);

        return speed;
    }

    protected function collideArtery (arteryType :int) :void
    {
        // get rid of cells
        var cellDisplay :DisplayObject;
        for each (cellDisplay in _redCells) {
            cellDisplay.parent.removeChild(cellDisplay);
        }
        for each (cellDisplay in _whiteCells) {
            cellDisplay.parent.removeChild(cellDisplay);
        }
        _redCells = [];
        _whiteCells = [];

        _lastArtery = arteryType;
        updateArteryHilite();

        // Deliver a white cell to the heart, to slow the beat down
        GameCtx.heart.deliverWhiteCell();

        // animate the white cell delivery
        var sprite :Sprite = SpriteUtil.createSprite();
        sprite.addChild(ClientCtx.createCellBitmap(Constants.CELL_WHITE));
        var animationObj :SceneObject = new SimpleSceneObject(sprite);
        animationObj.x = Constants.GAME_CTR.x;
        animationObj.y = this.y;
        animationObj.addTask(ScaleTask.CreateSmooth(2, 2, 1));
        animationObj.addTask(new SerialTask(
            LocationTask.CreateEaseIn(Constants.GAME_CTR.x, Constants.GAME_CTR.y, 1),
            new SelfDestructTask()));
        GameCtx.gameMode.addObject(animationObj, GameCtx.cellLayer);
    }

    protected function updateArteryHilite () :void
    {
        GameCtx.gameMode.hiliteArteries(
            _lastArtery != Constants.ARTERY_TOP,
            _lastArtery != Constants.ARTERY_BOTTOM);
    }

    protected function canCollideArtery (arteryType :int) :Boolean
    {
        return _lastArtery != arteryType && _whiteCells.length > 0;
    }

    protected var _redCells :Array = [];
    protected var _whiteCells :Array = [];

    protected var _lastArtery :int = -1;
}

}
