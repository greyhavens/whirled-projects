package server {

import com.threerings.util.Log;

public class ServerLocalUtility
    implements LocalUtility
{
    public function resetScores () :void
    {
        // no-op
    }

    public function setScore (playerId :int, score :int) :void
    {
        // no-op
    }

    public function incrementScore (playerId :int, delta :int) :void
    {
        // no-op
    }

    public function feedback (msg :String) :void
    {
        log.info(msg);
    }

    protected static const log :Log = Log.getLog(ServerLocalUtility);
}

}
