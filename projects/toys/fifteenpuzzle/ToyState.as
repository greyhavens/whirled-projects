//
// $Id$

package {

import flash.events.Event;
import flash.events.EventDispatcher;

import flash.utils.getTimer; // function import

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.threerings.util.ValueEvent;

/**
 * The state updated event. Dispatched
 * @eventType ToyState.STATE_UPDATED
 */
[Event(name="stateUpdated", type="flash.events.Event")]

public class ToyState extends EventDispatcher
{
    /** Event type constant. */
    public static const STATE_UPDATED :String = "stateUpdated";

    /**
     * ToyState constructor.
     * 
     // TODO
     * @param prefKey to persist the state on the client browser between instances, so that
     *                the toy starts with the last set state when viewed in inventory
     *                for any particular user.
     * @param deleteCount how many personalized states to save before some are deleted.
     */
    public function ToyState (ctrl :FurniControl,
        nonOwnersCanSave :Boolean = true, idleOutTimer :int = 30, deleteCount :int = 7)
    {
        if (ctrl.isConnected()) {
            _ctrl = ctrl;
            _nonOwnersCanSave = nonOwnersCanSave;

            _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);

            _myId = _ctrl.getInstanceId();
            _deleteCount = deleteCount;
            findFollowState();
        }

        _idleDelay = idleOutTimer * 1000;
    }

    /**
     * Get the state, or null if it's not set.
     */
    public function getState () :Object
    {
        return _state;
    }

    /**
     * Set the state. Ignores any states set by other clients.
     */
    public function setState (state :Object) :void
    {
        _state = state;
        _seqId++;
        _followKey = null;
        setTimeout();
        if (isSaving()) {
            _ctrl.updateMemory(STATE_PREFIX + _myId, [ _seqId, state ]);
        }
    }

    /**
     * Completely reset the state.
     */
    public function resetState () :void
    {
        _state = null;
        _seqId = 0;
        _followKey = RESET_KEY;
        setTimeout();
        if (isSaving()) {
            for (var key :String in _ctrl.getMemories()) {
                if (STATE_KEY.test(key)) {
                    _ctrl.updateMemory(key, null); // kaboom!
                }
            }
            _ctrl.updateMemory(RESET_KEY, [ 0, null ]);
        }
    }

    /**
     * Are we saving the state changes that the local user is making? Can we?
     * Should we?
     */
    protected function isSaving () :Boolean
    {
        return (_ctrl != null && (_nonOwnersCanSave || _ctrl.canEditRoom()));
    }

    protected function setTimeout () :void
    {
        _timeout = getTimer() + _idleDelay;
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        var key :String = event.name;
        if (!STATE_KEY.test(key)) {
            return; // none of our business..
        }

        var incoming :Array = event.value as Array;
        if (incoming == null) {
            // ignore clears
            return;
        }

        if (key == RESET_KEY) {
            // clear our follow key, in case it recently updated
            if (_followKey != null) {
                if (_followKey != RESET_KEY) {
                    _seqId = 0;
                    _state = null;
                    dispatchEvent(new Event(STATE_UPDATED));
                }
                _ctrl.updateMemory(_followKey, null);
                _followKey = null;
                _timeout = 0;
            }
            return;
        }

        // follow a new key if it's time
        if (key != _followKey) {
            if (getTimer() < _timeout) {
//                dispatchEvent(new ValueEvent("rejected", incoming[1]));
                return; // not time yet...
            }
            _followKey = key;
        }

        _timeout = getTimer() + _idleDelay;
        _seqId = int(incoming[0]);
        _state = incoming[1];
        dispatchEvent(new Event(STATE_UPDATED));
    }

    protected function findFollowState () :void
    {
        var highId :int = 0;
        var lowId :int = int.MAX_VALUE;
        var high :Object;
        var highKey :String;
        var lowKey :String;
        var count :int = 0;
        var memories :Object = _ctrl.getMemories();
        for (var key :String in memories) {
            if (STATE_KEY.test(key)) {
                count++;
                var mem :Array = memories[key] as Array;
                var seqId :int = int(mem[0]);
                if (seqId > highId) {
                    if (highId == 0) {
                        lowKey = key; // it's also the low if we never see anything lower
                    }
                    highId = seqId;
                    highKey = key;
                    high = mem[1];

                } else if (seqId < lowId) {
                    lowId = seqId;
                    lowKey = key;
                }
            }
        }

        if (count >= _deleteCount) {
            _ctrl.updateMemory(lowKey, null);
        }

        _followKey = highKey;
        setTimeout();
        _state = high;
        _seqId = highId;
    }

    protected static const STATE_PREFIX :String = "_s#";

    protected static const STATE_KEY :RegExp = /^_s\#\d+$/;

    protected static const RESET_KEY :String = STATE_PREFIX + "0";

    protected var _state :Object;

    protected var _seqId :int;

    protected var _ctrl :FurniControl;

    protected var _myId :int;

    protected var _nonOwnersCanSave :Boolean;

    protected var _idleDelay :int;

    protected var _timeout :Number = 0;

    protected var _followKey :String;

    protected var _deleteCount :int;
}
}
