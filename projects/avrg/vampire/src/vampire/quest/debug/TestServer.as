package vampire.quest.debug {

import com.whirled.contrib.avrg.oneroom.OneRoomGameServer;

import vampire.feeding.*;

/**
 * A test server for testing the quest system.
 */
public class TestServer extends OneRoomGameServer
{
    public function TestServer ()
    {
        OneRoomGameServer.roomType = TestGameController;
    }
}

}

import com.threerings.util.HashMap;
import com.threerings.util.ArrayUtil;

import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.ManagedTimer;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.variant.Variant;

class TestGameController extends OneRoomGameRoom
{
    override protected function finishInit () :void
    {
        super.finishInit();
        _events.registerListener(_gameCtrl.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
    }

    override public function shutdown () :void
    {
        _events.freeAllHandlers();
        _events = null;

        _timerMgr.shutdown();
        _timerMgr = null;

        super.shutdown();
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == "Client_Hello" && !ArrayUtil.contains(_players, e.senderId)) {
            _players.push(e.senderId);
            _gameCtrl.getPlayer(e.senderId).sendMessage("Server_Hello");
        }
    }

    override protected function playerLeft (playerId :int) :void
    {
        log.info("Player left server", "playerId", playerId);

        ArrayUtil.removeFirst(_players, playerId);
    }

    protected var _players :Array = [];

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();
}
