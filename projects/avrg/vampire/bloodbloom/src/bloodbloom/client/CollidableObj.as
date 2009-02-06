package bloodbloom.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.util.Collision;

public class CollidableObj extends NetObj
    implements LocationComponent, ScaleComponent
{
    public function CollidableObj (radius :Number = 0)
    {
        _radius = radius;
    }

    public function collidesWith (other :CollidableObj) :Boolean
    {
        return Collision.circlesIntersect(_loc, this.radius, other._loc, other.radius);
    }

    /*public function collides (otherLoc :Vector2, otherRadius :Number) :Boolean
    {
        return Collision.circlesIntersect(_loc, this.radius, otherLoc, otherRadius);
    }*/

    public function get radius () :Number
    {
        return _radius * _scale;
    }

    public function get x () :Number
    {
        return _loc.x;
    }

    public function get y () :Number
    {
        return _loc.y;
    }

    public function set x (val :Number) :void
    {
        _loc.x = val;
    }

    public function set y (val :Number) :void
    {
        _loc.y = val;
    }

    public function get loc () :Vector2
    {
        return _loc;
    }

    public function get scaleX () :Number
    {
        return _scale;
    }

    public function get scaleY () :Number
    {
        return _scale;
    }

    public function set scaleX (val :Number) :void
    {
        _scale = val;
    }

    public function set scaleY (val :Number) :void
    {
        _scale = val;
    }

    public function get scale () :Number
    {
        return _scale;
    }

    public function set scale (val :Number) :void
    {
        _scale = val;
    }

    protected var _radius :Number = 0;
    protected var _loc :Vector2 = new Vector2();
    protected var _scale :Number = 1;
}

}
