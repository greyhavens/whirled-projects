//
// $Id$

package locksmith.model {

import com.threerings.util.Log;
import com.threerings.util.HashMap;
import com.threerings.util.ValueEvent;

import com.whirled.game.GameControl;

import com.whirled.contrib.EventHandlerManager;

[Event(name="pointScored", type="com.threerings.util.ValueEvent")]
[Event(name="ringsCreated", type="com.threerings.util.ValueEvent")]
[Event(name="ringPositionSet", type="locksmith.model.RingPositionEvent")]
[Event(name="marblePositionSet", type="locksmith.model.MarblePositionEvent")]
[Event(name="marbleAdded", type="lockmsith.model.MarbleAddedEvent")]

public class RingManager extends ModelManager
{
    public static const RING_HOLES :String = "RingManagerRingHoles";
    public static const EXISTING_MARBLES :String = "RingManagerExistingMarbles";
    public static const RING_POSITION :String = "RingManagerRingPosition";
    public static const MARBLE_POSITION :String = "RingManagerMarblePosition";

    public static const RING_POSITIONS :int = 16;
    public static const NUM_RINGS :int = 4;

    // server-side events
    public static const POINT_SCORED :String = "pointScored";

    // client-side events
    public static const RINGS_CREATED :String = "ringsCreated";
    public static const RING_POSITION_SET :String = "ringPositionSet";
    public static const MARBLE_POSITION_SET :String = "marblePositionSet";
    public static const MARBLE_ADDED :String = "marbleAdded";

    // message sent from clients to request ring rotation on their turn
    public static const RING_ROTATION :String = "RingManagerRingRotation";

    public function RingManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        super(gameCtrl, eventMgr);
        manageProperties(RING_HOLES, EXISTING_MARBLES, RING_POSITION, MARBLE_POSITION);
    }

    public function get smallestRing () :Ring
    {
        return _rings[0] as Ring;
    }

    public function createRings () :void
    {
        requireServer();
        startBatch();
        for (var ring :int = 0; ring < NUM_RINGS; ring++) {
            var holes :Array = [];
            for (var hole :int = 0; hole < RING_HOLE_NUM[ring]; hole++) {
                var pos :int;
                do {
                    pos = Math.floor(Math.random() * RING_POSITIONS);
                } while (pos % RING_HOLE_MOD[ring] != 0 || holes.indexOf(pos) >= 0);
                holes.push(pos);
            }
            setIn(RING_HOLES, ring, holes);
            setIn(RING_POSITION, ring, 0);
        }
        commitBatch();
    }

    public function requestRingRotation (ring :Ring, direction :RotationDirection) :void
    {
        requireClient();
        dispatchClientRequest(RING_ROTATION, {ring: ring.id, direction: direction.name()});
    }

    public function rotateRing (id :int, direction :RotationDirection) :void
    {
        requireServer();
        if (direction == RotationDirection.NO_ROTATION) {
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
                    marble = outerRing.outer.removeMarbleIn(ii);
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
            // TODO: newValue is null!?
            log.debug("creating ring", "holes", newValue);
            var outer :Ring = new Ring(key, newValue as Array);
            if (inner != null) {
                inner.outer = outer;
                outer.inner = inner;
            }
            _rings.push(outer);
            if (key == NUM_RINGS - 1) {
                // pass out the smallest ring, the listener can get the rest from it.
                dispatchEvent(new ValueEvent(RINGS_CREATED, _rings[0]));
            }

        } else if (prop == RING_POSITION && onClient()) {
            var ring :Ring = _rings[key] as Ring;
            var direction :RotationDirection = ring.setPosition(newValue as int);
            dispatchEvent(new RingPositionEvent(ring, direction));

        } else if (prop == MARBLE_POSITION && onClient()) {
            var ringId :int = newValue.ring;
            ring = ringId == GOAL_RING_ID || ringId == LAUNCHER_RING_ID ? 
                null : _rings[ringId] as Ring;
            var position :int = newValue.pos;
            var marble :Marble = _marbles.get(key) as Marble;
            if (ringId == LAUNCHER_RING_ID) {
                dispatchEvent(new MarbleAddedEvent(marble, position));
            } else {
                dispatchEvent(new MarblePositionEvent(ring, marble, position));
            }

        } else if (prop == EXISTING_MARBLES && onClient()) {
            if (oldValue == null) {
                marble = new Marble(key, Player.valueOf(newValue as String));
                _marbles.put(key, marble);
            } else {
                _marbles.remove(key);
            }
        }
    }

    public function loadLaunchers () :void
    {
        requireServer();
        startBatch();
        var sunLaunchers :Array = Player.SUN.launchers;
        var moonLaunchers :Array = Player.MOON.launchers;
        for (var ii :int = 0; ii < sunLaunchers.length; ii++) {
            var sunMarble :Marble = new Marble(_nextMarbleId++, Player.SUN);
            _marbles.put(sunMarble.id, sunMarble);
            // EXISTING_MARBLES is around so we don't have to keep the player of each marble 
            // persisted in the MARBLE_POSITION property dictionary.
            setIn(EXISTING_MARBLES, sunMarble.id, Player.SUN.name());
            setIn(MARBLE_POSITION, sunMarble.id, 
                {ring: LAUNCHER_RING_ID, pos: Player.SUN.launchers[ii]});

            var moonMarble :Marble = new Marble(_nextMarbleId++, Player.MOON);
            _marbles.put(moonMarble.id, moonMarble);
            setIn(EXISTING_MARBLES, moonMarble.id, Player.MOON.name());
            setIn(MARBLE_POSITION, moonMarble.id,
                {ring: LAUNCHER_RING_ID, pos: Player.MOON.launchers[ii]});
        }
        commitBatch();
    }

    protected function innerRingPath (ring :Ring, position :int) :int
    {
        if (ring.inner != null && ring.inner.positionOpen(position)) {
            return innerRingPath(ring.inner, position);

        } else if (ring.inner != null) {
            return ring.id;

        } else {
            var player :Player = Player.MOON.goals.indexOf(position) >= 0 ? Player.MOON :
                (Player.SUN.goals.indexOf(position) >= 0 ? Player.SUN : null);
            if (player != null) {
                dispatchEvent(new ValueEvent(POINT_SCORED, player));
                return GOAL_RING_ID;
            } else {
                return ring.id;
            }
        }
    }

    protected var _rings :Array = [];
    protected var _marbles :HashMap = new HashMap();
    protected var _nextMarbleId :int = 0; // only used on the server.

    protected static const RING_HOLE_NUM :Array = [ 2, 4, 8, 6 ];
    protected static const RING_HOLE_MOD :Array = [ 4, 2, 1, 2 ];
    protected static const GOAL_RING_ID :int = -10;
    protected static const LAUNCHER_RING_ID :int = -11;

    private static const log :Log = Log.getLog(RingManager);
}
}
