//
// $Id$

package locksmith {

import flash.display.DisplayObject;

import com.whirled.contrib.EventHandlerManager;

public class LocksmithController 
{
    public function LocksmithController (display :DisplayObject) 
    {
        _gameCtrl = new GameControl(display);
        _eventMgr = createEventManager();
        _model = new LocksmithModel(_gameCtrl, _eventMgr);
    }

    public function createEventManager () :EventHandlerManager
    {
        var eventMgr :EventHandlerManager = new EventHandlerManager();
        eventMgr.registerUnload(_gameCtrl);
        return eventMgr;
    }

    protected var _gameCtrl :GameControl;
    protected var _model :LocksmithModel;
    protected var _eventMgr :EventHandlerManager;
}
}
