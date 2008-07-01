package {

import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.MessageReceivedEvent;
import com.threerings.util.StringUtil;

public class Server extends ServerObject
{
    public static const REQUEST_BACKEND_CALL :String = "request.backend.call";
    public static const BACKEND_CALL_RESULT :String = "backend.call.result";
    public static const CALLBACK_INVOKED :String = "callback.invoked";

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
                var args :Array = evt.value.params;
                var params :Array = fnSpec.parameters;
                for (var ii :int = 0; ii < args.length; ++ii) {
                    if (params[ii] is CallbackParameter && args[ii] != null) {
                        args[ii] = makeGenericCallback(evt.value, evt.senderId);
                    }
                }

                trace("Calling " + fnSpec.name + " with arguments " + 
                      StringUtil.toString(args));
                try {
                    var value :Object = fnSpec.func.apply(null, args);
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

    protected function makeGenericCallback (
        origMessage :Object,
        senderId :int) :Function
    {
        function callback (...args) :void {
            trace("Callback from " + origMessage.name + " invoked with " + 
                  "arguments " + StringUtil.toString(args));
            var msg :Object = {};
            msg.name = origMessage.name;
            msg.sequenceId = origMessage.sequenceId;
            msg.args = args;
            _ctrl.net.sendMessage(CALLBACK_INVOKED, msg, senderId);
        }

        return callback;
    }


    protected var _ctrl :GameControl;
    protected var _defs :Definitions;
}

}
