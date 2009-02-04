package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.contrib.simplegame.util.Collision;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Cell extends SceneObject
{
    public static function getCellCount (type :int) :int
    {
        return ClientCtx.mainLoop.topMode.getObjectRefsInGroup("Cell_" + type).length;
    }

    public static function getCellCollision (loc :Vector2, radius :Number, cellType :int = -1) :Cell
    {
        // returns the first cell that collides with the given circle
        var groupName :String = (cellType == -1 ? "Cell" : "Cell_" + cellType);
        var cells :Array = ClientCtx.mainLoop.topMode.getObjectRefsInGroup(groupName);

        for each (var cellRef :SimObjectRef in cells) {
            var cell :Cell = cellRef.object as Cell;
            if (cell != null &&
                Collision.circlesIntersect(cell._loc, Constants.CELL_RADIUS, loc, radius)) {
                return cell;
            }
        }

        return null;
    }

    public function Cell (type :int, fadeIn :Boolean)
    {
        _type = type;

        _sprite = new Sprite();
        _sprite.addChild(ClientCtx.createCellBitmap(type));

        _moveCCW = Rand.nextBoolean(Rand.STREAM_GAME);

        // fade in
        if (fadeIn) {
            this.alpha = 0;
            addTask(new AlphaTask(1, 0.4));
        }
    }

    override protected function update (dt :Number) :void
    {
        _loc.x = this.x;
        _loc.y = this.y;

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
        this.x = _loc.x;
        this.y = _loc.y;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return "Cell_" + _type;
        case 1:     return "Cell";
        default:    return super.getObjectGroup(groupNum - 2);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
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
    protected var _sprite :Sprite;
    protected var _moveCCW :Boolean;
    protected var _loc :Vector2 = new Vector2();
    protected var _followObj :SimObjectRef = SimObjectRef.Null();

    protected static const SPEED_BASE :Number = 5;
    protected static const SPEED_FOLLOW :Number = 7;
}

}
