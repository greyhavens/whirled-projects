//
// $Id$

package locksmith.model {

import com.threerings.util.Log;

import com.whirled.game.GameControl;

import com.whirled.contrib.EventHandlerManager;

public class RingManager extends ModelManager
{
    public static const RING_HOLES :String = "RingManagerRingHoles";
    public static const RING_POSITION :String = "RingManagerRingPositions";

    public static const RING_POSITIONS :int = 16;

    public function RingManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        super(gameCtrl, eventMgr);
        manageProperties(RING_HOLES, RING_POSITION);
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
            for (var position :int = 0; position < RING_POSITIONS; position++) {
                // TODO: marble stuff.
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
            _rings.push(new Ring(key, newValue as Array));
        }
    }

    protected var _rings :Array = [];

    protected static const NUM_RINGS :int = 4;
    protected static const RING_HOLE_NUM :Array = [ 2, 4, 8, 6 ];
    protected static const RING_HOLE_MOD :Array = [ 4, 8, 16, 8 ];

    private static const log :Log = Log.getLog(RingManager);
}
}
