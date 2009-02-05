package bloodbloom.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

public class Cell extends CollidableObj
    implements NetObj
{
    public static const STATE_BIRTH :int = 0;
    public static const STATE_NORMAL :int = 1;

    public static function getCellCount (cellType :int = -1) :int
    {
        var groupName :String = (cellType == -1 ? "Cell" : "Cell_" + cellType);
        return ClientCtx.heartbeatDb.getObjectRefsInGroup(groupName).length;
    }

    public static function getCellCollision (loc :Vector2, radius :Number, cellType :int = -1) :Cell
    {
        // returns the first cell that collides with the given circle
        var groupName :String = (cellType == -1 ? "Cell" : "Cell_" + cellType);
        var cells :Array = ClientCtx.heartbeatDb.getObjectRefsInGroup(groupName);

        for each (var cellRef :SimObjectRef in cells) {
            var cell :Cell = cellRef.object as Cell;
            if (cell != null &&
                cell._state == STATE_NORMAL &&
                cell.collides(loc, radius)) {
                return cell;
            }
        }

        return null;
    }

    public function Cell (type :int, beingBorn :Boolean)
    {
        super(Constants.CELL_RADIUS);

        _type = type;

        _moveCCW = Rand.nextBoolean(Rand.STREAM_GAME);

        if (beingBorn) {
            // When cells are born, they burst out of the center of the heart
            _state = STATE_BIRTH;
            this.x = Constants.GAME_CTR.x;
            this.y = Constants.GAME_CTR.y;

            // fire out of the heart in a random direction
            var angle :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_GAME);
            var distRange :NumRange = Constants.CELL_BIRTH_DISTANCE[_type];
            var dist :Number = distRange.next();
            var target :Vector2 = Vector2.fromAngle(angle, dist).addLocal(Constants.GAME_CTR);

            addTask(new SerialTask(
                LocationTask.CreateEaseOut(target.x, target.y, Constants.CELL_BIRTH_TIME),
                new FunctionTask(
                    function () :void {
                        _state = STATE_NORMAL;
                    })));

        } else {
            _state = STATE_NORMAL;
        }
    }

    override protected function update (dt :Number) :void
    {
        // white cells follow predators who have other white cells attached
        /*if (this.isWhiteCell) {
            var cellHemisphere :int = ClientCtx.getHemisphere(this);

            if (this.isFollowing && !canFollow(this.followingPredator)) {
                // stop following the predator if it's left our hemisphere
                stopFollowing();
            }

            if (!this.isFollowing) {
                // find somebody to follow
                for each (var predator :PredatorCursor in PredatorCursor.getAll()) {
                    if (canFollow(predator)) {
                        follow(predator);
                        break;
                    }
                }
            }
        }*/

        if (_state == STATE_NORMAL) {
            // if we're following somebody, move towards them
            if (this.isFollowing) {
                var following :PredatorCursor = this.followingPredator;
                var followImpulse :Vector2 = new Vector2(following.x, following.y).subtractLocal(_loc);
                followImpulse.length = SPEED_FOLLOW * dt;
                _loc.x += followImpulse.x;
                _loc.y += followImpulse.y;

            } else {
                // otherwise, move away from, and around, the heart
                var ctrImpulse :Vector2 = _loc.subtract(Constants.GAME_CTR);
                ctrImpulse.length = 1;

                var perpImpulse :Vector2 = ctrImpulse.getPerp(_moveCCW);
                perpImpulse.length = 3.5;

                var impulse :Vector2 = ctrImpulse.add(perpImpulse);
                impulse.length = SPEED_BASE * dt;

                _loc.x += impulse.x;
                _loc.y += impulse.y;
            }

            _loc = ClientCtx.clampLoc(_loc);
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return "Cell_" + _type;
        case 1:     return "Cell";
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

    protected function canFollow (predator :PredatorCursor) :Boolean
    {
        return (predator.numWhiteCells > 0 &&
                ClientCtx.getHemisphere(predator) == ClientCtx.getHemisphere(this));
    }

    protected function follow (predator :PredatorCursor) :void
    {
        _followObj = predator.ref;
    }

    protected function stopFollowing () :void
    {
        _followObj = SimObjectRef.Null();
    }

    protected function get followingPredator () :PredatorCursor
    {
        return _followObj.object as PredatorCursor;
    }

    protected function get isFollowing () :Boolean
    {
        return !_followObj.isNull;
    }

    protected var _type :int;
    protected var _state :int;
    protected var _moveCCW :Boolean;
    protected var _followObj :SimObjectRef = SimObjectRef.Null();

    protected static const SPEED_BASE :Number = 5;
    protected static const SPEED_FOLLOW :Number = 7;
}

}
