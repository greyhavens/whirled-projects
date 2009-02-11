package bloodbloom.client {

import bloodbloom.*;

import com.threerings.flash.MathUtil;
import com.threerings.flash.Vector2;

public class PlayerCursor extends CollidableObj
{
    public function PlayerCursor ()
    {
        _radius = Constants.CURSOR_RADIUS;
    }

    public function set moveTarget (val :Vector2) :void
    {
        _moveDirection = val.subtract(_loc).normalizeLocal();
    }

    public function updateLoc (dt :Number) :void
    {
        var moveDist :Number = this.speed * dt;
        _loc.x += (_moveDirection.x * moveDist);
        _loc.y += (_moveDirection.y * moveDist);
        _loc = GameCtx.clampLoc(_loc);
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        updateLoc(dt);
    }

    public function offsetSpeedPenalty (offset :Number) :void
    {
        _speedPenalty = Math.max(_speedPenalty + offset, 0);
    }

    public function offsetSpeedBonus (offset :Number) :void
    {
        _speedBonus = Math.max(_speedBonus + offset, 0);
    }

    protected function get speed () :Number
    {
        return MathUtil.clamp(_speedBase + _speedBonus - _speedPenalty, _speedMin, _speedMax);
    }

    protected function init (speedBase :Number, speedMin :Number, speedMax :Number) :void
    {
        _speedBase = speedBase;
        _speedMin = speedMin;
        _speedMax = speedMax;
    }

    protected var _moveDirection :Vector2 = new Vector2();
    protected var _speedMin :Number = 0;
    protected var _speedMax :Number = 0;
    protected var _speedBase :Number = 0;
    protected var _speedPenalty :Number = 0;
    protected var _speedBonus :Number = 0;
}

}
