package vampire.quest.debug {

import com.whirled.contrib.avrg.oneroom.OneRoomGameServer;

import vampire.feeding.*;

/**
 * A test server for testing the quest system.
 */
public class QuestTestServer extends OneRoomGameServer
{
    public function QuestTestServer ()
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
    }

    override public function shutdown () :void
    {
        _events.freeAllHandlers();
        _events = null;

        _timerMgr.shutdown();
        _timerMgr = null;

        super.shutdown();
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();
}
