package starfight {

import com.threerings.util.Log;
import com.whirled.game.GameControl;

public class LocalUtility
{
    public function LocalUtility (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
    }

    public function feedback (msg :String) :void
    {
        if (AppContext.gameCtrl.game.amServerAgent()) {
            log.info(msg);
        } else {
            AppContext.gameCtrl.local.feedback(msg);
        }
    }

    protected var _gameCtrl :GameControl;

    protected static const log :Log = Log.getLog("FEEDBACK:");
}

}
