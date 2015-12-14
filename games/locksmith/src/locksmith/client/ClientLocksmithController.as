//
// $Id$

package locksmith.client {

import flash.display.Sprite;

import com.threerings.util.Log;
import com.threerings.util.ValueEvent;

import com.whirled.game.SizeChangedEvent;

import locksmith.LocksmithController;
import locksmith.model.MarbleAddedEvent;
import locksmith.model.MarblePositionEvent;
import locksmith.model.RingManager;
import locksmith.model.RingPositionEvent;
import locksmith.view.LocksmithView;

public class ClientLocksmithController extends LocksmithController
{
    public function ClientLocksmithController (sprite :Sprite)
    {
        super(sprite);

        if (!_gameCtrl.game.isConnected()) {
            log.info("Game control is not connected, ceasing game display");
            return;
        }

        // TODO: make rematching work
        _gameCtrl.local.setShowReplay(false);
        _eventMgr.registerListener(_gameCtrl.local, SizeChangedEvent.SIZE_CHANGED, updateSize);

        _view = new LocksmithView(_model, this);
        _view.updateSize(_gameCtrl.local.getSize());
        sprite.addChild(_view);

        _eventMgr.registerListener(
            _model.ringMgr, RingManager.RING_POSITION_SET, ringPositionSet);
        _eventMgr.registerListener(
            _model.ringMgr, RingManager.MARBLE_POSITION_SET, marblePositionSet);
        _eventMgr.registerListener(
            _model.ringMgr, RingManager.MARBLE_ADDED, marbleAdded);
    }

    protected function ringPositionSet (event :RingPositionEvent) :void
    {
        // TODO
    }

    protected function marblePositionSet (event :MarblePositionEvent) :void
    {
        // TODO
    }

    protected function marbleAdded (event :MarbleAddedEvent) :void
    {
        // TODO
    }

    protected function updateSize (...ignored) :void
    {
        _view.updateSize(_gameCtrl.local.getSize());
    }

    protected var _view :LocksmithView;

    private static const log :Log = Log.getLog(ClientLocksmithController);
}
}
