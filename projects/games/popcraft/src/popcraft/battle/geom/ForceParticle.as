package popcraft.battle.geom {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.util.PerfUtil;

public class ForceParticle
{
    public function ForceParticle (container :ForceParticleContainer, x :Number, y :Number) :void
    {
        _container = container;
        this.setLoc(x, y);
    }

    public function destroy () :void
    {
        _container.removeParticle(this);
    }

    public function setLoc (x :Number, y :Number) :void
    {
        _loc.x = x;
        _loc.y = y;
        _container.addParticle(this, x, y);
    }

    /** Discover all the forces that apply to this particle. */
    public function getCurrentForce (forceQueryRadius :Number) :Vector2
    {
        var timer :String = PerfUtil.startTimer("getCurrentForce");

        var forceQueryRadiusInv :Number = 1 / forceQueryRadius;

        var force :Vector2 = new Vector2();

        this.getForceFromBucket(_container.getBucket(_col - 1, _row - 1), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col,     _row - 1), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col + 1, _row - 1), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col - 1, _row    ), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col,     _row    ), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col + 1, _row    ), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col - 1, _row + 1), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col,     _row + 1), force, forceQueryRadius);
        this.getForceFromBucket(_container.getBucket(_col + 1, _row + 1), force, forceQueryRadius);

        PerfUtil.stopTimer(timer);

        return force;
    }

    protected function getForceFromBucket (head :ForceParticle, force :Vector2, forceQueryRadius :Number) :void
    {
        var forceQueryRadiusInv :Number = 1 / forceQueryRadius;

        var p :ForceParticle = head;
        while (null != p) {
            if (this != p) {
                var vec :Vector2 = _loc.subtract(p._loc);

                // if this particle is directly on top of the other particle,
                // we'll get a zero vector, which we can't normalize.
                if (vec.x == 0 && vec.y == 0) {
                    // make a small non-zero vector
                    vec.x = 0.001;
                }

                var distance :Number = vec.normalizeLocalAndGetLength();
                if (distance < forceQueryRadius) {

                    // normalize the strength of each vector
                    var strength :Number = (forceQueryRadius - distance) * forceQueryRadiusInv;
                    vec.scaleLocal(strength);

                    // rotate the vector a bit
                    vec.rotateLocal(strength * MAX_ROTATION);

                    force.addLocal(vec);
                }
            }

            p = p._next;
        }
    }

    protected var _container :ForceParticleContainer;
    protected var _loc :Vector2 = new Vector2();


    // managed by ForceParticleContainer
    internal var _next :ForceParticle;
    internal var _prev :ForceParticle;
    internal var _bucketIdx :int = -1;
    internal var _col :int = -1;
    internal var _row :int = -1;

    protected static const MAX_ROTATION :Number = Math.PI / 4;
}

}
