package vampire.feeding.debug {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Sprite;
import flash.events.Event;

import vampire.feeding.FeedingGameClient;

public class TestClient extends Sprite
{
    public function TestClient ()
    {
        log.info("Starting TestClient");

        _gameCtrl = new AVRGameControl(this);
        FeedingGameClient.init(this, _gameCtrl);

        _events.registerListener(this, Event.REMOVED_FROM_STAGE, onQuit);
        _events.registerListener(_gameCtrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        // Tell the TestServer we're ready to start receiving messages. Real clients
        // probably won't need to do this - the client will have already started receiving
        // messages by the time feeding starts.
        _gameCtrl.agent.sendMessage("TestClientReady");
    }

    protected function onQuit (...ignored) :void
    {
        _events.freeAllHandlers();
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        // The TestServer sends the StartFeeding message when enough players have connected
        // to the game to start.
        if (e.name == "StartFeeding") {
            var gameId :int = e.value as int;
            log.info("Received StartFeeding message", "gameId", gameId);

            if (_curGame != null) {
                log.warning("Received StartFeeding message while already in game");
            } else {
                _curGame = FeedingGameClient.create(gameId, onGameComplete);
                addChild(_curGame);
            }
        }
    }

    protected function onGameComplete () :void
    {
        removeChild(_curGame);
        _curGame = null;

        // In the test client, we just disconnect from the game when it ends.
        _gameCtrl.player.deactivateGame();
    }


    protected var _gameCtrl :AVRGameControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _curGame :FeedingGameClient;

    protected static var log :Log = Log.getLog(TestClient);
}

}
