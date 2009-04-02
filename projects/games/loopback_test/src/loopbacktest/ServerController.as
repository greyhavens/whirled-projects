package loopbacktest {

import com.threerings.util.Log;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.UserChatEvent;
import com.whirled.game.loopback.LoopbackGameControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;

public class ServerController
{
    public function ServerController (host :DisplayObject)
    {
        _gameCtrl = new LoopbackGameControl(host, true, false);

        // Handle events
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            function (e :MessageReceivedEvent) :void {
                log.info("MsgReceived", "name", e.name, "val", e.value);
            });

        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED,
            function (e :PropertyChangedEvent) :void {
                log.info("PropChanged", "name", e.name, "newVal", e.newValue,
                              "oldVal", e.oldValue);
            });

        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED,
            function (e :ElementChangedEvent) :void {
                log.info("ElemChanged", "name", e.name, "key", e.key, "newVal", e.newValue,
                    "oldVal", e.oldValue);
            });

        _gameCtrl.game.addEventListener(UserChatEvent.USER_CHAT,
            function (e :UserChatEvent) :void {
                log.info("UserChat", "speaker", e.speaker, "msg", e.message);
            });

        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED,
            function (e :StateChangedEvent) :void {
                log.info("Game started");
            });

        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED,
            function (e :StateChangedEvent) :void {
                log.info("Game ended");
            });

        _gameCtrl.game.addEventListener(StateChangedEvent.ROUND_STARTED,
            function (e :StateChangedEvent) :void {
                log.info("Round started", "roundId", _gameCtrl.game.getRound());
            });

        _gameCtrl.game.addEventListener(StateChangedEvent.ROUND_ENDED,
            function (e :StateChangedEvent) :void {
                log.info("Round ended", "roundId", _gameCtrl.game.getRound());
            });
    }

    protected var _gameCtrl :GameControl;

    protected static var log :Log = Log.getLog(Server);
}

}
