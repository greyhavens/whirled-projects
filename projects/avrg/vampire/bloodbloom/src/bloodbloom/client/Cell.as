package bloodbloom.client {

import bloodbloom.*;

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

public class Cell extends CollidableObj
{
    public static const STATE_BIRTH :int = 0;
    public static const STATE_NORMAL :int = 1;

    public static function destroyCells (cellType :int = -1) :void
    {
        GameCtx.gameMode.destroyObjectsInGroup(getGroupName(cellType));
    }

    public static function getCellCount (cellType :int = -1) :int
    {
        return GameCtx.gameMode.getObjectRefsInGroup(getGroupName(cellType)).length;
    }

    public static function getCellCollision (obj :CollidableObj, cellType :int = -1) :Cell
    {
        // returns the first cell that collides with the given circle
        var cells :Array = GameCtx.gameMode.getObjectRefsInGroup(getGroupName(cellType));

        for each (var cellRef :SimObjectRef in cells) {
            var cell :Cell = cellRef.object as Cell;
            if (cell != null &&
                cell._state == STATE_NORMAL &&
                cell.collidesWith(obj)) {
                return cell;
            }
        }

        return null;
    }

    public static function getBirthTargetLoc (cellType :int) :Vector2
    {
         // fire out of the heart in a random direction
        var angle :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_GAME);
        var distRange :NumRange = Constants.CELL_BIRTH_DISTANCE[cellType];
        var dist :Number = distRange.next();
        return Vector2.fromAngle(angle, dist).addLocal(Constants.GAME_CTR);
    }

    public function Cell (type :int, beingBorn :Boolean)
    {
        _radius = Constants.CELL_RADIUS;
        _type = type;

        _moveCCW = Rand.nextBoolean(Rand.STREAM_GAME);

        if (beingBorn) {
            // When cells are born, they burst out of the center of the heart
            _state = STATE_BIRTH;
            this.x = Constants.GAME_CTR.x;
            this.y = Constants.GAME_CTR.y;

            // fire out of the heart in a random direction
            _birthTarget = getBirthTargetLoc(_type);
            addTask(new SerialTask(
                LocationTask.CreateEaseOut(_birthTarget.x, _birthTarget.y, Constants.CELL_BIRTH_TIME),
                new FunctionTask(function () :void {
                    _state = STATE_NORMAL;
                })));

        } else {
            _state = STATE_NORMAL;
        }
    }

    public function getNextLoc (curLoc :Vector2, dt :Number) :Vector2
    {
        var nextLoc :Vector2 = curLoc.clone();
        if (_state == STATE_NORMAL) {

            // white cells follow predators who have other white cells attached
            if (this.isWhiteCell) {
                if (this.isFollowing && !canFollow(this.followingCursor)) {
                    // stop following the predator if it's left our hemisphere
                    stopFollowing();
                }

                if (!this.isFollowing && canFollow(GameCtx.cursor)) {
                    follow(GameCtx.cursor);
                }
            }

            // if we're following somebody, move towards them
            if (this.isFollowing) {
                var following :PlayerCursor = this.followingCursor;
                var followImpulse :Vector2 =
                    new Vector2(following.x, following.y).subtractLocal(nextLoc);
                followImpulse.length = SPEED_FOLLOW * dt;
                nextLoc.x += followImpulse.x;
                nextLoc.y += followImpulse.y;

            } else {
                // otherwise, move away from, and around, the heart
                var ctrImpulse :Vector2 = nextLoc.subtract(Constants.GAME_CTR);
                ctrImpulse.length = 1;

                var perpImpulse :Vector2 = ctrImpulse.getPerp(_moveCCW);
                perpImpulse.length = 3.5;

                var impulse :Vector2 = ctrImpulse.add(perpImpulse);
                impulse.length = SPEED_BASE * dt;

                nextLoc.x += impulse.x;
                nextLoc.y += impulse.y;
            }

            nextLoc = GameCtx.clampLoc(nextLoc);
        }

        return nextLoc;
    }

    override protected function update (dt :Number) :void
    {
        _loc = getNextLoc(_loc, dt);
        super.update(dt);
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return getGroupName(_type);
        case 1:     return getGroupName(-1);
        default:    return super.getObjectGroup(groupNum - 2);
        }
    }

    public function get type () :int
    {
        return _type;
    }

    public function get isRedCell () :Boolean
    {
        return _type == Constants.CELL_RED;
    }

    public function get isWhiteCell () :Boolean
    {
        return _type == Constants.CELL_WHITE;
    }

    public function get state () :int
    {
        return _state;
    }

    protected function canFollow (cursor :PlayerCursor) :Boolean
    {
        return (cursor.numWhiteCells > 0 &&
                GameCtx.getHemisphere(cursor) == GameCtx.getHemisphere(this));
    }

    protected function follow (cursor :PlayerCursor) :void
    {
        _followObj = cursor.ref;
    }

    protected function stopFollowing () :void
    {
        _followObj = SimObjectRef.Null();
    }

    protected function get followingCursor () :PlayerCursor
    {
        return _followObj.object as PlayerCursor;
    }

    protected function get isFollowing () :Boolean
    {
        return !_followObj.isNull;
    }

    protected static function getGroupName (cellType :int) :String
    {
        return (cellType < 0 ? "Cell" : "Cell_" + cellType);
    }

    protected var _type :int;
    protected var _state :int;
    protected var _moveCCW :Boolean;
    protected var _followObj :SimObjectRef = SimObjectRef.Null();
    protected var _birthTarget :Vector2;

    protected static const SPEED_BASE :Number = 5;
    protected static const SPEED_FOLLOW :Number = 7;
}

}
