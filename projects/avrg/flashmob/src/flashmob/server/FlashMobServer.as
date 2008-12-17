package flashmob.server {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;

public class FlashMobServer extends ServerObject
{
    public static var log :Log = Log.getLog(FlashMobServer);

    public function FlashMobServer ()
    {
        ServerContext.gameCtrl = new AVRServerGameControl(this);
    }

    protected function startGame (partyId :int) :void
    {
        if (_games.put(partyId, new MobGameController(partyId)) !== undefined) {
            log.warning("Started multiple games with the same partyId (" + partyId + ")");
        }
    }

    protected function endGame (partyId :int) :void
    {
        var ctrl :MobGameController = _games.remove(partyId);
        if (ctrl != null) {
            ctrl.shutdown();
        } else {
            log.warning("Tried to end non existent game (partyId=" + partyId + ")");
        }
    }

    protected function getGame (partyId :int) :MobGameController
    {
        return _games.get(partyId);
    }

    protected var _games :HashMap = new HashMap();
}

}
