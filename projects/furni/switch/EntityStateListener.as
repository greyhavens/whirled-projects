package {

import flash.events.EventDispatcher;

import com.threerings.util.NameValueEvent;
import com.threerings.util.ValueEvent;
import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;

/**
 * This class should be instantiated by any entity (a lamp, for example) that wishes to
 * synchronize with another entity (a lightswitch, for example) that is broadcasting some
 * part of its state using a {@link EntityStatePublisher}.
 *
 * When we intercept a state change signal with the right key, we dispatch an event which
 * our instantiating entity may respond to. When first instantiated, we send out a special
 * signal that request a re-broadcast of the publisher's state.
 */
public class EntityStateListener extends EventDispatcher
{
    public function EntityStateListener (control :EntityControl, key :String)
    {
        _key = key;
        _control = control;
        _control.sendSignal("_q_" + key);
        _control.addEventListener(ControlEvent.SIGNAL_RECEIVED, handleSignal);
    }

    public function get state () :Object
    {
        return _state;
    }

    protected function handleSignal (event :ControlEvent) :void
    {
        Log.getLog(this).debug("handleSignal(" + event + ")");
        if (event.name == "_s_" + _key) {
            if (_stateSet == false || event.value != _state) {
                _stateSet = true;
                _state = event.value;
                dispatchEvent(new EntityStateEvent(EntityStateEvent.STATE_CHANGED, _key, _state));
            }
        }
    }

    protected var _control :EntityControl;

    protected var _key :String;
    protected var _stateSet :Boolean;
    protected var _state :Object;
}
}
