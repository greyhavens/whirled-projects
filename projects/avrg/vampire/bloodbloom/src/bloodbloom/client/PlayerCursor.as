package bloodbloom.client {

import bloodbloom.*;

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.util.Collision;

public class PlayerCursor extends CollidableObj
{
    public function PlayerCursor ()
    {
        super(Constants.CURSOR_RADIUS);
    }

    public function get moveTarget () :Vector2
    {
        return _moveTarget;
    }

    public function set moveTarget (val :Vector2) :void
    {
        _moveTarget = val;
        _mode = MODE_FOLLOWING_TARGET;
    }

    public function updateLoc (dt :Number) :void
    {
        var moveDist :Number = this.speed * dt;
        if (moveDist <= 0 || (_mode == MODE_FOLLOWING_TARGET && _loc.equals(_moveTarget))) {
            return;
        }

        var newLoc :Vector2;
        if (_mode == MODE_FOLLOWING_TARGET) {
            // if we're in "following target" mode, we try to move closer to the target
            newLoc = _moveTarget.subtract(_loc);
            var targetDist :Number = newLoc.normalizeLocalAndGetLength();
            var actualDist :Number = Math.min(targetDist, moveDist);
            newLoc.scaleLocal(actualDist);
            newLoc = GameCtx.clampLoc(newLoc.addLocal(_loc));

            // if we hit our target this frame, switch to "moving forward" mode
            if (!_loc.equals(newLoc) &&
                Collision.minDistanceFromPointToLineSegment(_moveTarget, _loc, newLoc) == 0) {
                _mode = MODE_MOVING_FORWARD;
                _moveDirection = newLoc.subtract(_loc).normalizeLocal();
                moveDist -= actualDist;
            }

            _loc = newLoc;
        }

         if (_mode == MODE_MOVING_FORWARD) {
            // move in a straight line
            _loc.x += (_moveDirection.x * moveDist);
            _loc.y += (_moveDirection.y * moveDist);
            _loc = GameCtx.clampLoc(_loc);
         }
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        updateLoc(dt);
    }

    protected function get speed () :Number
    {
        return 0;
    }

    override public function clone (theClone :CollidableObj = null) :CollidableObj
    {
        if (theClone == null) {
            theClone = new PlayerCursor();
        }

        var cursorClone :PlayerCursor = PlayerCursor(theClone);
        super.clone(cursorClone);

        cursorClone._moveTarget = _moveTarget.clone();
        cursorClone._moveDirection = _moveDirection.clone();
        cursorClone._mode = _mode;

        return cursorClone;
    }

    protected var _moveTarget :Vector2 = new Vector2();
    protected var _moveDirection :Vector2 = new Vector2();
    protected var _mode :int;

    protected static const MODE_FOLLOWING_TARGET :int = 0;
    protected static const MODE_MOVING_FORWARD :int = 1;
}

}
