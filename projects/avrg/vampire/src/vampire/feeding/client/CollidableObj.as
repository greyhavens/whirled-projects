package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.util.Collision;

public class CollidableObj extends SceneObject
{
    public function collidesWith (other :CollidableObj) :Boolean
    {
        return Collision.circlesIntersect(_loc, this.radius, other.loc, other.radius);
    }

    public function get radius () :Number
    {
        return _radius * this.scaleX;
    }

    override public function get x () :Number
    {
        return _loc.x;
    }

    override public function get y () :Number
    {
        return _loc.y;
    }

    override public function set x (val :Number) :void
    {
        _loc.x = val;
    }

    override public function set y (val :Number) :void
    {
        _loc.y = val;
    }

    public function get loc () :Vector2
    {
        return _loc;
    }

    protected var _radius :Number = 0;
    protected var _loc :Vector2 = new Vector2();
}

}
