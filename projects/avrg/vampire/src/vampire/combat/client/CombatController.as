package vampire.combat.client
{
import aduros.net.REMOTE;
import aduros.net.RemoteProxy;

import com.threerings.util.ClassUtil;
import com.threerings.util.Controller;
import com.threerings.util.Log;

import flash.events.IEventDispatcher;

public class CombatController extends Controller
{
    public static const NEXT :String = "Next";

    public function CombatController(panel :IEventDispatcher, ctx :CombatGameCtx,
        gameService :RemoteProxy)
    {
        _ctx = ctx;
        setControlledPanel(panel);
    }


    REMOTE function doThingClient ( arg :int) :void
    {
        log.debug("doThingClient",  "arg", arg);
    }

    public function handleNext () :void
    {
        _ctx.modeStack.pop();
        _ctx.panel.modeLabel.text = ClassUtil.tinyClassName(_ctx.modeStack.top());
    }

    protected function get ctx () :CombatGameCtx
    {
        return _ctx;
    }

    protected var _gameService :RemoteProxy;
    protected var _ctx :CombatGameCtx;
    protected static var log :Log = Log.getLog(CombatController);

}
}