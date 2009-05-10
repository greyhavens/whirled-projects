package vampire.server
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.contrib.CheatDetector;
import com.whirled.contrib.simplegame.EventCollecter;
import com.whirled.net.MessageReceivedEvent;

import vampire.data.Codes;

public class CheatHandler extends EventCollecter
{
    public function CheatHandler(ctrl :AVRServerGameControl)
    {
        _ctrl = ctrl;
        _events.registerListener(ctrl.game, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);
        _events.freeAllOn(ctrl);
    }

    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
         if (e.name == CheatDetector.PLAYER_CHEATED) {
            log.error(CheatDetector.PLAYER_CHEATED, e.value);
            var playerId :int = (e.value as Array)[0];
            var cheaters :Array = _ctrl.props.get(Codes.AGENT_PROP_CHEATER_IDS) as Array;
            if (cheaters == null) {
                cheaters = new Array();
            }
            if (!ArrayUtil.contains(cheaters, playerId)) {
                cheaters.push(playerId);
                _ctrl.props.set(Codes.AGENT_PROP_CHEATER_IDS, cheaters)
            }
         }
    }

    protected var _ctrl :AVRServerGameControl;
    protected static const log :Log = Log.getLog(CheatHandler);

}
}