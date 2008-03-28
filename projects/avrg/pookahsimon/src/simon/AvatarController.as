package simon {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.*;

public class AvatarController extends SimObject
{
    public static const NAME :String = "AvatarController";

    public static function get instance () :AvatarController
    {
        return MainLoop.instance.topMode.getObjectNamed(NAME) as AvatarController;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    public function setAvatarState (newState :String, revertAfterSeconds :Number = 0, revertToState :String = null) :void
    {
        if (!SimonMain.control.isConnected()) {
            return;
        }

        this.stopTimer();

        if (revertAfterSeconds > 0 && revertToState != null) {

            // if we already have a saved state, then we're already
            // playing a temporary state
            // @TODO - getAvatarInfo.state is broken (always null). Revert when it's fixed
            /*if (null != _savedState) {
                _savedState = SimonMain.control.getAvatarInfo(SimonMain.localPlayerId).state;
            }*/

            _savedState = revertToState;

            this.addNamedTask(
                AVATAR_REVERT_TASK_NAME,
                After(revertAfterSeconds, new FunctionTask(revertToSavedState)));
        }

        var infoString :String = "setting state to '" + newState + "'";
        if (revertAfterSeconds > 0) {
            infoString += " (will revert to '" + _savedState + "' after " + revertAfterSeconds + " seconds)";
        }

        log.info(infoString);

        SimonMain.control.setAvatarState(newState);
    }

    protected function stopTimer () :void
    {
        this.removeNamedTasks(AVATAR_REVERT_TASK_NAME);
    }

    protected function revertToSavedState (...ignored) :void
    {
        if (null != _savedState) {
            SimonMain.control.setAvatarState(_savedState);
            _savedState = null;
        }
    }

    protected var _savedState :String;

    protected static var log :Log = Log.getLog(AvatarController);

    protected static const AVATAR_REVERT_TASK_NAME :String = "AvatarRevert";

}

}
