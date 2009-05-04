package vampire.quest.server {

import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.net.MessageReceivedEvent;

import vampire.quest.*;

public class Server
{
    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
    }

    public static function shutdown () :void
    {
        _gameCtrl.game.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
    }

    protected static function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == QuestMessages.TIMESTAMP) {
            var playerCtrl :PlayerSubControlServer = _gameCtrl.getPlayer(e.senderId);
            if (playerCtrl != null) {
                playerCtrl.sendMessage(QuestMessages.TIMESTAMP, new Date().time);
            }
        }
    }

    protected static var _gameCtrl :AVRServerGameControl;

    protected static var log :Log = Log.getLog(Server);
}

}
