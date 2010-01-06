package vampire.feeding.client {

import com.threerings.geom.Vector2;
import com.threerings.flashbang.components.*;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.util.Collision;

public class CollidableObj extends SceneObject
{
    public function collidesWith (other :CollidableObj) :Boolean
    {
        return Collision.circlesIntersect(this.loc, this.radius, other.loc, other.radius);
    }

    public function get radius () :Number
    {
        return _radius * this.scaleX;
    }

    public function get loc () :Vector2
    {
        return new Vector2(this.x, this.y);
    }

    protected var _radius :Number = 0;
}

}
