package {

import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.MessageReceivedEvent;
import com.threerings.util.StringUtil;

public class Server extends ServerObject
{
    public static const REQUEST_BACKEND_CALL :String = "rbc";
    public static const BACKEND_CALL_RESULT :String = "bcr";

    public function Server ()
    {
        _ctrl = new GameControl(this);
        _defs = new Definitions(_ctrl);

        _ctrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, 
            handleMessage);
    }

    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == REQUEST_BACKEND_CALL) {
            trace("Handling message " + evt);
            var result :Object = {};
            result.sequenceId = evt.value.sequenceId;
            var fnSpec :FunctionSpec = _defs.findByName(evt.value.name);
            if (fnSpec == null) {
                result.status = "failed";
                result.reason = "Function " + evt.name + " not found";

            } else {
                try {
                    trace("Calling " + fnSpec.name + " with arguments " + 
                          StringUtil.toString(evt.value.params));
                    var value :Object = fnSpec.func.apply(
                        null, evt.value.params);
                    trace("Result: " + StringUtil.toString(value));
                    result.status = "succeeded";
                    result.result = value;

                } catch (e :Error) {
                    var msg :String = e.getStackTrace();
                    if (msg == null) {
                        msg = e.toString();
                    }
                    trace(msg);
                    result.status = "failed";
                    result.reason = "Function raised an exception:\n" + msg;
                }
            }

            _ctrl.net.sendMessage(BACKEND_CALL_RESULT, result, evt.senderId);
        }
    }

    protected var _ctrl :GameControl;
    protected var _defs :Definitions;
}

}
