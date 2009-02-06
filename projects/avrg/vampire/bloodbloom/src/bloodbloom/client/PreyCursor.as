package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

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
        var cell :Cell = Cell.getCellCollision(this);
        if (cell != null) {
            cell.destroySelf();
            if (cell.type == Constants.CELL_RED) {
                _redCellCount++;
            } else {
                _whiteCellCount++;
            }

            dispatchEvent(new GameEvent(GameEvent.ATTACHED_CELL, cell));
        }

        // collide with the arteries
        var crossedCtr :Boolean =
            (_loc.x >= Constants.GAME_CTR.x && _lastLoc.x < Constants.GAME_CTR.x) ||
            (_loc.x < Constants.GAME_CTR.x && _lastLoc.x >= Constants.GAME_CTR.x);

        var artery :int = -1;
        if (crossedCtr) {
            if (_loc.y < Constants.GAME_CTR.y && canCollideArtery(Constants.ARTERY_TOP)) {
                artery = Constants.ARTERY_TOP;
            } else if (_loc.y >= Constants.GAME_CTR.y && canCollideArtery(Constants.ARTERY_BOTTOM)) {
                artery = Constants.ARTERY_BOTTOM;
            }

            if (artery != -1) {
                collideArtery(artery);
            } else {
                // we're prevented from crossing the artery
                _loc.x = (_loc.x >= Constants.GAME_CTR.x ?
                            Constants.GAME_CTR.x - 1 : Constants.GAME_CTR.x);
            }
        }

        _lastLoc = _loc.clone();
    }

    override protected function get speed () :Number
    {
        var speed :Number = Math.max(
            Constants.PREY_SPEED_BASE + (Constants.PREY_SPEED_CELL_OFFSET * _redCellCount),
            Constants.PREY_SPEED_MIN);

        return speed;
    }

    protected function collideArtery (arteryType :int) :void
    {
        // get rid of cells
        _redCellCount = 0;
        _whiteCellCount = 0;
        dispatchEvent(new GameEvent(GameEvent.DETACHED_ALL_CELLS));

        _lastArtery = arteryType;
        updateArteryHilite();

        // Deliver a white cell to the heart, to slow the beat down
        GameCtx.heart.deliverWhiteCell();

        // animate the white cell delivery
        /*var sprite :Sprite = SpriteUtil.createSprite();
        sprite.addChild(ClientCtx.createCellBitmap(Constants.CELL_WHITE));
        var animationObj :SceneObject = new SimpleSceneObject(sprite);
        animationObj.x = Constants.GAME_CTR.x;
        animationObj.y = this.y;
        animationObj.addTask(ScaleTask.CreateSmooth(2, 2, 1));
        animationObj.addTask(new SerialTask(
            LocationTask.CreateEaseIn(Constants.GAME_CTR.x, Constants.GAME_CTR.y, 1),
            new SelfDestructTask()));
        GameCtx.gameMode.addObject(animationObj, GameCtx.cellLayer);*/
    }

    protected function updateArteryHilite () :void
    {
        GameCtx.gameMode.hiliteArteries(
            _lastArtery != Constants.ARTERY_TOP,
            _lastArtery != Constants.ARTERY_BOTTOM);
    }

    protected function canCollideArtery (arteryType :int) :Boolean
    {
        return _lastArtery != arteryType && _whiteCellCount > 0;
    }

    protected var _redCellCount :int;
    protected var _whiteCellCount :int;
    protected var _lastLoc :Vector2 = new Vector2();

    protected var _lastArtery :int = -1;
}

}
