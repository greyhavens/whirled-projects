package vampire.avatar {

import com.threerings.util.Log;
import com.whirled.AvatarControl;
import com.whirled.contrib.EventHandlerManager;

import flash.display.MovieClip;
import flash.events.Event;

public class VampireBody extends Body
{
    public function VampireBody (ctrl :AvatarControl, media :MovieClip, width :int, height :int = -1)
    {
        super(ctrl, media, width, height);
        ctrl.registerPropertyProvider(propertyProvider);
        _events.registerListener(ctrl, Event.UNLOAD, onUnload);
    }

    public function freeze (val :Boolean) :void
    {
        if (val != _isFrozen) {
            log.info("Changing frozen status to " + val);
            _isFrozen = val;
            // If we're unfreezing, transition to whatever our current state should be
            if (!_isFrozen && _pendingState != null) {
                super.switchToState(_pendingState);
                _pendingState = null;
            } else if (_isFrozen) {
                // TODO: do we want to switch to a state, or dispatch an event and let
                // the avatar figure out the best course of action, or stop the current
                // animation, or what?
                _pendingState = _state;
                super.switchToState("Frozen");
            }
        }
    }

    override public function switchToState (state :String) :void
    {
        if (_isFrozen) {
            _pendingState = state;
            log.info("Delaying state change while frozen", "state", state);
        } else {
            super.switchToState(state);
        }
    }

    override public function triggerAction (action :String) :void
    {
        // Don't play actions while we're frozen
        if (!_isFrozen) {
            super.triggerAction(action);
        } else {
            log.info("Skipping action while frozen", "action", action);
        }
    }

    protected function propertyProvider (key :String) :Object
    {
        if (key == "freeze") {
            // avoid compiler warning about implicit cast from Function to Object
            return freeze as Object;
        }

        return null;
    }

    protected function onUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        _events = null;
    }

    protected var _isFrozen :Boolean;
    protected var _pendingState :String;

    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var log :Log = Log.getLog(VampireBody);
}

}
