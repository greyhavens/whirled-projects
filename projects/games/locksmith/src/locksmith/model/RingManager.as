//
// $Id$

package locksmith.model {

import com.threerings.util.Log;
import com.threerings.util.ValueEvent;

import com.whirled.game.GameControl;

import com.whirled.contrib.EventHandlerManager;

[Event(name="pointScored", type="com.threerings.util.ValueEvent")]

public class RingManager extends ModelManager
{
    public static const RING_HOLES :String = "RingManagerRingHoles";
    public static const RING_POSITION :String = "RingManagerRingPosition";
    public static const MARBLE_POSITION :String = "RingManagerMarblePosition";

    public static const RING_POSITIONS :int = 16;

    public static const POINT_SCORED :String = "pointScored";

    public function RingManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        super(gameCtrl, eventMgr);
        manageProperties(RING_HOLES, RING_POSITION, MARBLE_POSITION);
    }

    public function createRings () :void
    {
        requireServer();
        startBatch();
        var holes :Array;
        for (var ring :int = 1; ring <= NUM_RINGS; ring++) {
            holes = [];
            for (var hole :int = 0; hole < RING_HOLE_NUM[ring]; hole++) {
                var pos :int;
                do {
                    pos = Math.floor(Math.random() * RING_POSITIONS);
                } while (pos % RING_HOLE_MOD[ring] != 0 || holes.indexOf(pos) >= 0);
                holes.push(pos);
            }
            setIn(RING_HOLES, ring - 1, holes);
            setIn(RING_POSITIONS, ring - 1, 0);
        }
        commitBatch();
    }

    public function rotateRing (id :int, direction :RotationDirection) :void
    {
        requireServer();
        if (direction == RingDirection.NO_ROTATION) {
            // nothin' doin'
            return;
        }

        startBatch();
        var ring :Ring = _rings[id] as Ring;
        for (var phase :int = 0; phase < 4; phase++) {
            setIn(RING_POSITION, id, ring.modifyPosition(direction));
            for (var ii :int = 0; ii < RING_POSITIONS; ii++) {
                if (ring.positionContainsMarble(ii)) {
                    var innerId :int = innerRingPath(ring, ii);
                    if (innerId != ring.id) {
                        var marble :Marble = ring.removeMarbleIn(ii);
                        if (innerId != GOAL_RING_ID) {
                            (_rings[innerId] as Ring).addMarble(ii, marble);
                        }
                        setIn(MARBLE_POSITION, marble.id, {ring: innerId, pos: ii});
                    }
                }

                var outerRing :Ring = ring;
                while (outerRing.outer != null && outerRing.outer.positionContainsMarble(ii) &&
                    outerRing.positionOpen(ii)) {
                    var marble :Marble = outerRing.outer.removeMarble(ii);
                    if (phase == 4) {
                        innerId = innerRingPath(outerRing, ii);
                        if (innerId != GOAL_RING_ID) {
                            (_rings[innerId] as Ring).addMarble(ii, marble);
                        }
                        setIn(MARBLE_POSITION, marble.id, {ring: innerId, pos: ii});

                    } else {
                        outerRing.addMarble(ii, marble);
                        setIn(MARBLE_POSITION, marble.id, {ring: outerRing.id, pos: ii});
                    }
                    outerRing = outerRing.outer;
                }
            }
        }
        commitBatch();
    }

    override protected function managedPropertyUpdated (prop :String, newValue :Object, 
        oldValue :Object, key :int = -1) :void
    {
        if (prop == RING_HOLES) {
            if (key != _rings.length) {
                log.warning("Received a ring out of order", "ring", key, "_rings.length", 
                    _rings.length);
                return;
            }
            var inner :Ring = _rings.length == 0 ? null : _rings[_rings.length - 1] as Ring;
            var outer :Ring = new Ring(key, newValue as Array);
            if (inner != null) {
                inner.outer = outer;
                outer.inner = inner;
            }
            _rings.push(outer);
        }
    }

    protected function innerRingPath (ring :Ring, position :int) :int
    {
        if (ring.inner != null && ring.inner.positionOpen(ii)) {
            return innerRingPath(ring.inner, position);

        } else if (ring.inner != null) {
            return ring.id;

        } else {
            var player :Player = Player.MOON.goals.indexOf(ii) >= 0 ? Player.MOON :
                (Player.SUN.goals.indexOf(ii) >= 0) ? Player.SUN : null);
            if (player != null) {
                dispatchEvent(new ValueEvent(POINT_SCORED, player));
                return GOAL_RING_ID;
            } else {
                return ring.id;
            }
        }
    }

    protected var _rings :Array = [];

    protected static const NUM_RINGS :int = 4;
    protected static const RING_HOLE_NUM :Array = [ 2, 4, 8, 6 ];
    protected static const RING_HOLE_MOD :Array = [ 4, 8, 16, 8 ];
    protected static const GOAL_RING_ID :int = -10;

    private static const log :Log = Log.getLog(RingManager);
}
}
