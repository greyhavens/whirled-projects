package vampire.feeding.client {

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import vampire.feeding.*;
import vampire.server.Trophies;

public class PlayerCursor extends CollidableObj
{
    public function PlayerCursor ()
    {
        _radius = Constants.CURSOR_RADIUS;

        _movie = ClientCtx.instantiateMovieClip(
            "blood", (ClientCtx.isCorruption ? "cursor" : "cursor_corruption"), true, true);
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        if (ClientCtx.settings.canDropWhiteCells || ClientCtx.settings.playerCreatesWhiteCells) {
            registerListener(GameCtx.bgLayer, MouseEvent.MOUSE_DOWN, onMouseDown);
        }

        if (ClientCtx.settings.playerCreatesWhiteCells) {
            _createdWhiteCell = Cell.createCellSprite(Constants.CELL_WHITE, 0, false);
            _createdWhiteCell.y = -(_movie.height * 0.35);
            _sprite.addChildAt(_createdWhiteCell, 0);
            respawnWhiteCell();
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
    }

    protected function onMouseDown (e :MouseEvent) :void
    {
        if (this.isWhiteCellSpawned) {
            var cell :Cell = GameObjects.createCell(Constants.CELL_WHITE, true);
            var loc :Point = new Point(_createdWhiteCell.x, _createdWhiteCell.y);
            loc = DisplayUtil.transformPoint(loc, _createdWhiteCell.parent, GameCtx.cellLayer);
            cell.x = loc.x;
            cell.y = loc.y;

            respawnWhiteCell();

        } else if (ClientCtx.settings.canDropWhiteCells) {
            dropCells();
        }
    }

    protected function respawnWhiteCell () :void
    {
        _createdWhiteCell.scaleX = _createdWhiteCell.scaleY = 0;
        var time :Number = ClientCtx.settings.playerWhiteCellCreationTime;
        var pauseTime :Number = Math.max(time - 0.25, 0);
        var growTime :Number = time - pauseTime;
        addNamedTask(
            RESPAWN_WHITE_CELL_TASK,
            After(pauseTime, TargetedScaleTask.CreateEaseIn(_createdWhiteCell, 1, 1, growTime)));
    }

    protected function get isWhiteCellSpawned () :Boolean
    {
        return (ClientCtx.settings.playerCreatesWhiteCells && !this.isWhiteCellSpawning);
    }

    protected function get isWhiteCellSpawning () :Boolean
    {
        return hasTasksNamed(RESPAWN_WHITE_CELL_TASK);
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (!GameCtx.gameOver) {
            var curLoc :Vector2 = this.loc;

            // Move towards the mouse
            var moveTarget :Vector2 =
                new Vector2(GameCtx.cellLayer.mouseX, GameCtx.cellLayer.mouseY);
            if (!moveTarget.equals(curLoc) && !moveTarget.equals(_lastMoveTarget)) {
                _moveDirection = moveTarget.subtract(curLoc).normalizeLocal();
                _lastMoveTarget = moveTarget;
            }

            // update location
            var moveDist :Number = Constants.CURSOR_SPEED * dt;
            curLoc.x += (_moveDirection.x * moveDist);
            curLoc.y += (_moveDirection.y * moveDist);
            curLoc = GameCtx.clampLoc(curLoc);

            // collide with cells
            handleCollisions(curLoc);

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
    }

    protected function attachCell (cell :Cell) :void
    {
        var loc :Point = DisplayUtil.transformPoint(
            new Point(cell.x, cell.y),
            cell.displayObject.parent,
            _sprite);
        cell.x = loc.x;
        cell.y = loc.y;
        _sprite.addChild(cell.displayObject);
        _attachedWhiteCells.push(cell.ref);

        cell.attachToCursor(this);
    }

    protected function dropCells () :void
    {
        if (_attachedWhiteCells.length > 0) {
            var loc :Point = new Point();
            for each (var cellRef :SimObjectRef in _attachedWhiteCells) {
                var cell :Cell = cellRef.object as Cell;
                if (cell != null) {
                    loc.x = cell.x;
                    loc.y = cell.y;
                    loc = DisplayUtil.transformPoint(loc, _sprite, GameCtx.cellLayer);
                    cell.x = loc.x;
                    cell.y = loc.y;
                    GameCtx.cellLayer.addChild(cell.displayObject);
                    cell.detachFromCursor();
                }
            }

            _attachedWhiteCells = [];
        }
    }

    protected function handleCollisions (curLoc :Vector2) :void
    {
        var cell :Cell = Cell.getCellCollision(this);
        if (cell != null) {
            if (cell.type == Constants.CELL_WHITE) {
                if (ClientCtx.settings.playerCarriesWhiteCells && cell.canAttach) {
                    attachCell(cell);
                }

            } else if (cell.type == Constants.CELL_SPECIAL) {
                cell.destroySelf();
                //GameObjects.createWhiteBurst(cell);
                //GameObjects.createSpecialBloodAnim(cell);
                GameCtx.gameMode.addSceneObject(
                    new LostSpecialStrainAnim(cell.specialStrain, cell.x, cell.y),
                    GameCtx.effectLayer);

                cell.destroySelf();

            } else {
                // create a cell burst
                GameObjects.createRedBurst(cell);
                dispatchEvent(new GameEvent(GameEvent.HIT_RED_CELL));
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
    }

    protected function collideArtery (arteryType :int) :void
    {
        // get rid of cells
        var numWhiteCells :int;
        if (_attachedWhiteCells.length > 0) {
            for each (var cellRef :SimObjectRef in _attachedWhiteCells) {
                if (!cellRef.isNull) {
                    numWhiteCells++;
                    cellRef.object.destroySelf();
                }
            }

            _attachedWhiteCells = [];
        }

        // Award a trophy for delivering a bunch of white cells
        if (numWhiteCells >= Trophies.CONSTANT_GARDENER_REQ) {
            ClientCtx.awardTrophy(Trophies.CONSTANT_GARDENER);
        }

        _lastArtery = arteryType;

        // Deliver a white cell to the heart
        if (numWhiteCells > 0) {
            GameCtx.gameMode.deliverWhiteCell(arteryType);
        } else if (this.isWhiteCellSpawned) {
            GameCtx.gameMode.deliverWhiteCell(arteryType);
            respawnWhiteCell();
        }
    }

    protected function canCollideArtery (arteryType :int) :Boolean
    {
        return true;
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;
    protected var _createdWhiteCell :Sprite;

    protected var _moveDirection :Vector2 = new Vector2();
    protected var _lastMoveTarget :Vector2 = new Vector2();

    protected var _attachedWhiteCells :Array = [];

    protected var _lastLoc :Vector2 = new Vector2();
    protected var _lastArtery :int = -1;

    protected static const ROTATE_SPEED :Number = 180; // degrees/second

    protected static const RESPAWN_WHITE_CELL_TASK :String = "RespawnWhiteCell";
}

}

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.components.AlphaComponent;
import com.whirled.contrib.simplegame.util.Interpolator;
import com.whirled.contrib.simplegame.util.MXInterpolatorAdapter;

import mx.effects.easing.*;
import flash.display.DisplayObject;

class TargetedScaleTask
    implements ObjectTask
{
    public static function CreateLinear (target :DisplayObject, x :Number, y :Number, time :Number)
        :TargetedScaleTask
    {
        return new TargetedScaleTask(
            target,
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (target :DisplayObject, x :Number, y :Number, time :Number)
        :TargetedScaleTask
    {
        return new TargetedScaleTask(
            target,
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (target :DisplayObject, x :Number, y :Number, time :Number)
        :TargetedScaleTask
    {
        return new TargetedScaleTask(
            target,
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (target :DisplayObject, x :Number, y :Number, time :Number)
        :TargetedScaleTask
    {
        return new TargetedScaleTask(
            target,
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public function TargetedScaleTask (
        target :DisplayObject,
        x :Number,
        y :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        _target = target;
        _toX = x;
        _toY = y;
        _totalTime = Math.max(time, 0);
        _interpolator = interpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        if (0 == _elapsedTime) {
            _fromX = _target.scaleX;
            _fromY = _target.scaleY;
        }

        _elapsedTime += dt;

        _target.scaleX = _interpolator.interpolate(_fromX, _toX, _elapsedTime, _totalTime);
        _target.scaleY = _interpolator.interpolate(_fromY, _toY, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new TargetedScaleTask(_target, _toX, _toY, _totalTime, _interpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _target :DisplayObject;

    protected var _interpolator :Interpolator;

    protected var _toX :Number;
    protected var _toY :Number;

    protected var _fromX :Number;
    protected var _fromY :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}
