package vampire.client
{
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;

import vampire.net.messages.StatsMsg;

public class AnalyserClient extends SimObject
{
    public function AnalyserClient()
    {
        registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);
    }
    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == StatsMsg.NAME) {
            var msg :StatsMsg = ClientContext.msg.deserializeMessage(StatsMsg.NAME,
                e.value as ByteArray) as StatsMsg;
            if (msg == null) {
                log.error("handleMessageReceived, cannot convert to StatsMsg", "e", e);
                return;
            }
            trace("Stats=\n");
            trace(msg.statsString);
        }
    }

    protected static const log :Log = Log.getLog(AnalyserClient);
}
}