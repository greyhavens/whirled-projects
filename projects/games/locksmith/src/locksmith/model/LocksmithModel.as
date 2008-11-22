//
// $Id$

package locksmith.model {

import com.whirled.contrib.EventHandlerManager;

public class LocksmithModel
{
    public function LocksmithModel (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        _gameCtrl = gameCtrl;
        _eventMgr  = eventMgr;

        _ringMgr = new RingManager(gameCtrl, _eventMgr);
    }

    public function get ringMgr () :RingManager
    {
        return _ringMgr;
    }

    protected var _stateMgr :GameStateManager;
    protected var _ringMgr :RingManager;
    protected var _eventMgr :EventHandlerManager;
}
}
