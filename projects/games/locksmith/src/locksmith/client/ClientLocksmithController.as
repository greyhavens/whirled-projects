//
// $Id$

package locksmith.client {

import flash.display.Sprite;

import com.threerings.util.ValueEvent;

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

        if (_gameCtrl.game.isConnected()) {
            // TODO: make rematching work
            _gameCtrl.local.setShowReplay(false);
        }

        _view = new LocksmithView(_model, this);
        sprite.addChild(_view);

        _eventMgr.registerListener(
            _model.ringMgr, RingManager.RINGS_CREATED, ringsCreated);
        _eventMgr.registerListener(
            _model.ringMgr, RingManager.RING_POSITION_SET, ringPositionSet);
        _eventMgr.registerListener(
            _model.ringMgr, RingManager.MARBLE_POSITION_SET, marblePositionSet);
        _eventMgr.registerListener(
            _model.ringMgr, RingManager.MARBLE_ADDED, marbleAdded);
    }

    protected function ringsCreated (event :ValueEvent) :void
    {
        // TODO event value is the smallest ring
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
}
}
