package vampire.feeding.client {

import com.threerings.flash.MathUtil;
import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.RotationTask;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;

import vampire.feeding.*;
import vampire.feeding.client.SpriteUtil;

public class PlayerCursor extends CollidableObj
{
    public function PlayerCursor ()
    {
        _radius = Constants.CURSOR_RADIUS;

        _movie = ClientCtx.instantiateMovieClip("blood", "cursor", true, true);
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
    }

    public function set moveTarget (val :Vector2) :void
    {
        _moveDirection = val.subtract(this.loc).normalizeLocal();
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        // update location
        var curLoc :Vector2 = this.loc;
        var moveDist :Number = this.speed * dt;
        curLoc.x += (_moveDirection.x * moveDist);
        curLoc.y += (_moveDirection.y * moveDist);
        curLoc = GameCtx.clampLoc(curLoc);

        // collide with cells
        var cell :Cell = Cell.getCellCollision(this);
        if (cell != null) {
            if (cell.type == Constants.CELL_WHITE) {
                var loc :Point = cell.displayObject.parent.localToGlobal(new Point(cell.x, cell.y));
                loc = _sprite.globalToLocal(loc);
                cell.x = loc.x;
                cell.y = loc.y;
                _sprite.addChild(cell.displayObject);
                _attachedWhiteCells.push(cell.ref);

                cell.attachToCursor(this);

            } else {
                // create a cell burst
                GameObjects.createRedBurst(cell);
            }
        }

        // collide with the arteries
        var crossedCtr :Boolean =
            (curLoc.x >= Constants.GAME_CTR.x && _lastLoc.x < Constants.GAME_CTR.x) ||
            (curLoc.x < Constants.GAME_CTR.x && _lastLoc.x >= Constants.GAME_CTR.x);

        var artery :int = -1;
        if (crossedCtr) {
            if (curLoc.y < Constants.GAME_CTR.y && canCollideArtery(Constants.ARTERY_TOP)) {
                artery = Constants.ARTERY_TOP;
            } else if (curLoc.y >= Constants.GAME_CTR.y && canCollideArtery(Constants.ARTERY_BOTTOM)) {
                artery = Constants.ARTERY_BOTTOM;
            }

            if (artery != -1) {
                collideArtery(artery);
            } else {
                // we're prevented from crossing the artery
                curLoc.x = (curLoc.x >= Constants.GAME_CTR.x ?
                            Constants.GAME_CTR.x - 1 : Constants.GAME_CTR.x);
            }
        }

        // rotate towards our move direction
        if (!curLoc.similar(_lastLoc, 0.5)) {
            // rotate towards our move direction. 0 degrees == straight down
            var targetRotation :Number =
                -90 + ((curLoc.subtract(_lastLoc).angle) * (180 / Math.PI));

            var curRotation :Number = this.rotation;
            if (targetRotation - curRotation > 180) {
                targetRotation -= 360;
            } else if (targetRotation - curRotation < -180) {
                targetRotation += 360;
            }

            addNamedTask(
                "Rotate",
                RotationTask.CreateEaseOut(
                    targetRotation,
                    Math.abs((targetRotation % 360) - curRotation) / ROTATE_SPEED),
                true);

        }

        _lastLoc = curLoc.clone();

        this.x = curLoc.x;
        this.y = curLoc.y;
    }

    public function offsetSpeedPenalty (offset :Number) :void
    {
        _speedPenalty = Math.max(_speedPenalty + offset, 0);
    }

    public function offsetSpeedBonus (offset :Number) :void
    {
        _speedBonus = Math.max(_speedBonus + offset, 0);
    }

    protected function collideArtery (arteryType :int) :void
    {
        // get rid of cells
        var hadWhiteCell :Boolean;
        for each (var cellRef :SimObjectRef in _attachedWhiteCells) {
            if (!cellRef.isNull) {
                hadWhiteCell = true;
                cellRef.object.destroySelf();
            }
        }

        _attachedWhiteCells = [];

        _lastArtery = arteryType;

        // Deliver a white cell to the heart
        if (hadWhiteCell) {
            dispatchEvent(new GameEvent(GameEvent.WHITE_CELL_DELIVERED));
        }

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

    protected function canCollideArtery (arteryType :int) :Boolean
    {
        return true;
    }

    protected function get speed () :Number
    {
        return MathUtil.clamp(
            Constants.CURSOR_SPEED_BASE + _speedBonus - _speedPenalty,
            Constants.CURSOR_SPEED_MIN,
            Constants.CURSOR_SPEED_MAX);
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;

    protected var _moveDirection :Vector2 = new Vector2();
    protected var _speedPenalty :Number = 0;
    protected var _speedBonus :Number = 0;

    protected var _attachedWhiteCells :Array = [];

    protected var _lastLoc :Vector2 = new Vector2();
    protected var _lastArtery :int = -1;

    protected static const ROTATE_SPEED :Number = 180; // degrees/second
}

}
