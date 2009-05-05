package vampire.quest.debug {

import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;

import vampire.quest.server.*;

/**
 * A test server for testing the quest system.
 */
public class QuestTestServer extends ServerObject
{
    public function QuestTestServer ()
    {
        _gameCtrl = new AVRServerGameControl(this);
        QuestServer.init(_gameCtrl);
    }

    protected var _gameCtrl :AVRServerGameControl;
}

}
