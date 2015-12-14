package vampire.feeding.client {

import vampire.feeding.net.CurrentScoreMsg;

import com.threerings.flashbang.GameObject;

public class LocalScoreReporter extends GameObject
{
    override protected function update (dt :Number) :void
    {
        _nextReportTime = Math.max(_nextReportTime - dt, 0);
        if (_nextReportTime == 0) {
            var score :int = GameCtx.score.bloodCount;
            if (score != _lastScore) {
                ClientCtx.msgMgr.sendMessage(
                    CurrentScoreMsg.create(ClientCtx.localPlayerId, score));
                _lastScore = score;
                _nextReportTime = MIN_UPDATE_PERIOD;
            }
        }
    }

    protected var _lastScore :int;
    protected var _nextReportTime :Number = 0;

    // don't send updates more than this frequently
    protected static const MIN_UPDATE_PERIOD :Number = 2;
}

}
