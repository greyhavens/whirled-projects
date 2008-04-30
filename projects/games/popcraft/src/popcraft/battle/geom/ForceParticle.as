package popcraft.battle.geom {

import com.threerings.flash.Vector2;

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.*;

public class ForceParticle extends SimObject
{
    public var loc :Vector2 = new Vector2();

    /** Discover all the forces that apply to this particle. */
    public function getCurrentForce (forceQueryRadius :Number) :Vector2
    {
        var forceQueryRadiusInv :Number = 1 / forceQueryRadius;

        var force :Vector2 = new Vector2();

        var refs :Array = GameContext.netObjects.getObjectRefsInGroup(GROUP_NAME);
        for each (var ref :SimObjectRef in refs) {
            var p :ForceParticle = ref.object as ForceParticle;
            if (null == p || this == p) {
                continue;
            }

            var vec :Vector2 = loc.subtract(p.loc);

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

        return force;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    protected static const MAX_ROTATION :Number = Math.PI / 4;
    protected static const GROUP_NAME :String = "ForceParticle";
}

}
