package vampire.feeding.client {

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.RotationTask;

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

        _movie = ClientCtx.instantiateMovieClip("blood", "cursor", true, true);
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        if (ClientCtx.settings.canDropWhiteCells) {
            registerListener(GameCtx.bgLayer, MouseEvent.MOUSE_DOWN, onMouseDown);
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
        if (ClientCtx.settings.canDropWhiteCells) {
            dropCells();
        }
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (!GameCtx.gameOver) {
            var curLoc :Vector2 = this.loc;

            // Move towards the mouse
            var moveTarget :Vector2 =
                new Vector2(GameCtx.cellLayer.mouseX, GameCtx.cellLayer.mouseY);
            if (!moveTarget.equals(curLoc)) {
                _moveDirection = moveTarget.subtract(curLoc).normalizeLocal();
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
                if (cell.canAttach) {
                    attachCell(cell);
                }

            } else if (cell.type == Constants.CELL_SPECIAL) {
                cell.destroySelf();
                //GameObjects.createWhiteBurst(cell);
                //GameObjects.createSpecialBloodAnim(cell);
                GameCtx.gameMode.addSceneObject(
                    new LostSpecialStrainAnim(cell.specialStrain, cell.x, cell.y),
                    GameCtx.uiLayer);

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
        for each (var cellRef :SimObjectRef in _attachedWhiteCells) {
            if (!cellRef.isNull) {
                numWhiteCells++;
                cellRef.object.destroySelf();
            }
        }

        _attachedWhiteCells = [];

        _lastArtery = arteryType;

        // Deliver a white cell to the heart
        if (numWhiteCells > 0) {
            GameCtx.gameMode.deliverWhiteCell(arteryType);
        }

        // Award a trophy for delivering a bunch of white cells
        if (numWhiteCells >= Trophies.CONSTANT_GARDENER_REQ) {
            ClientCtx.awardTrophy(Trophies.CONSTANT_GARDENER);
        }
    }

    protected function canCollideArtery (arteryType :int) :Boolean
    {
        return true;
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;

    protected var _moveDirection :Vector2 = new Vector2();

    protected var _attachedWhiteCells :Array = [];

    protected var _lastLoc :Vector2 = new Vector2();
    protected var _lastArtery :int = -1;

    protected static const ROTATE_SPEED :Number = 180; // degrees/second
}

}
