package vampire.feeding.debug {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.threerings.util.EventHandlerManager;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import vampire.data.Logic;
import vampire.feeding.*;

public class FeedingTestClient extends Sprite
{
    public function FeedingTestClient ()
    {
        log.info("Starting FeedingTestClient");

        _gameCtrl = new AVRGameControl(this);
        FeedingClient.init(this, _gameCtrl);

        _events.registerListener(this, Event.REMOVED_FROM_STAGE, onQuit);
        _events.registerListener(_gameCtrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        // Tell the TestServer we're ready to start receiving messages. Real clients
        // probably won't need to do this - the client will have already started receiving
        // messages by the time feeding starts. Keep sending the message until we
        // get a response from the server.
        _handshakeTimer = new Timer(1000);
        _events.registerListener(_handshakeTimer, TimerEvent.TIMER, sayHello);
        _handshakeTimer.start();
        sayHello();
    }

    protected function sayHello (...ignored) :void
    {
        _gameCtrl.agent.sendMessage("Client_Hello");
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
                var pfd :PlayerFeedingData = new PlayerFeedingData();
                pfd.playerStrain = Logic.getPlayerBloodStrain(_gameCtrl.player.getPlayerId());
                _curGame = FeedingClient.create(
                    FeedingClientSettings.mpSettings(gameId, pfd, onRoundComplete, onGameComplete));
            }

        } else if (e.name == "Server_Hello") {
            if (_handshakeTimer != null) {
                _events.unregisterListener(_handshakeTimer, TimerEvent.TIMER, sayHello);
                _handshakeTimer.stop();
                _handshakeTimer = null;
            }
        }
    }

    protected function onRoundComplete () :void
    {
        log.info("onRoundComplete");
    }

    protected function onGameComplete () :void
    {
        _curGame.shutdown();
        _curGame = null;

        // In the test client, we just disconnect from the game when it ends.
        _gameCtrl.player.deactivateGame();
    }

    protected var _gameCtrl :AVRGameControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _curGame :FeedingClient;
    protected var _handshakeTimer :Timer;

    protected static var log :Log = Log.getLog(FeedingTestClient);
}

}
