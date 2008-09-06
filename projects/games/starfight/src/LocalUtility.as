package {

import com.threerings.util.Log;

public class LocalUtility
{
    public function feedback (msg :String) :void
    {
        if (AppContext.gameCtrl.game.amServerAgent()) {
            log.info(msg);
        } else {
            AppContext.gameCtrl.local.feedback(msg);
        }
    }

    protected static const log :Log = Log.getLog("FEEDBACK:");
}

}
