package {

import flash.events.EventDispatcher;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;

import com.threerings.util.Log;

/**
 * This class should be instantiated by any entity (a lightswitch, for example) that wishes
 * to publish state to a room so that other entities (a lamp, for example) using the
 * {@link EntityStateListener} class, may synchronize with and respond to it.
 *
 * The state is persistently maintained using entity memory and stored under the given key.
 * It is broadcast using a signal when this object is first instantiated, when the state
 * changes as a result of calls to publishState(), or when another entity enters the scene
 * and requests a re-broadcast.
 */
public class EntityStatePublisher extends EventDispatcher
{
    public function EntityStatePublisher (control :EntityControl, key :String,
                                          defVal :Object = null)
    {
        _key = key;
        _control = control;
        _control.requestControl();
        _control.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChange);
        _control.addEventListener(ControlEvent.SIGNAL_RECEIVED, handleSignal);

        _state = _control.lookupMemory(_key, defVal);
        broadcastIfInControl();
    }

    public function get state () :Object
    {
        return _state;
    }

    public function publishState (state :Object) :void
    {
        if (state != _state) {
            _control.updateMemory(_key, state);
        }
    }

    protected function handleMemoryChange (event :ControlEvent) :void
    {
        if (event.name != _key) {
            return;
        }
        _state = event.value;
        dispatchEvent(new EntityStateEvent(EntityStateEvent.STATE_CHANGED, _key, _state));
        broadcastIfInControl();
    }

    protected function handleSignal (event :ControlEvent) :void
    {
        if (event.name == "_q_" + _key) {
            broadcastIfInControl();
        }
    }

    protected function broadcastIfInControl () :void
    {
        if (_control.hasControl()) {
            _control.sendSignal("_s_" + _key, _state);
        }
    }

    protected var _control :EntityControl;

    protected var _key :String;
    protected var _state :Object;
}
}
