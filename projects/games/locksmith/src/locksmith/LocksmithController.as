//
// $Id$

package locksmith {

import flash.display.DisplayObject;

import com.threerings.util.Log;
import com.threerings.util.ValueEvent;

import com.whirled.contrib.EventHandlerManager;

public class LocksmithController 
{
    public function LocksmithController (display :DisplayObject) 
    {
        _gameCtrl = new GameControl(display);
        _eventMgr = createEventManager();
        _model = new LocksmithModel(_gameCtrl, _eventMgr);

        _eventMgr.registerListener(_model.scoreMgr, ScoreManager.PLAYER_SCORED, playerScoredPoint);
    }

    public function createEventManager () :EventHandlerManager
    {
        var eventMgr :EventHandlerManager = new EventHandlerManager();
        eventMgr.registerUnload(_gameCtrl);
        return eventMgr;
    }

    protected function playerScoredPoint (event :ValueEvent) :void
    {
        log.info("Player scored point", "player", event.value);
    }

    protected var _gameCtrl :GameControl;
    protected var _model :LocksmithModel;
    protected var _eventMgr :EventHandlerManager;

    private static const log :Log = Log.getLog(LocksmithController);
}
}
