//
// $Id$

package locksmith.server {

import flash.display.DisplayObject;
import flash.events.TimerEvent;
import flash.utils.Timer;

import com.threerings.util.Log;
import com.threerings.util.ValueEvent;

import com.whirled.game.StateChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import locksmith.LocksmithController;
import locksmith.model.Player;
import locksmith.model.RingManager;
import locksmith.model.RotationDirection;
import locksmith.model.TurnManager;

public class ServerLocksmithController extends LocksmithController
{
    public function ServerLocksmithController (display :DisplayObject)
    {
        super(display);

        _eventMgr.registerListener(
            _gameCtrl.game, StateChangedEvent.GAME_STARTED, gameStarted);
        _eventMgr.registerListener(
            _gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _eventMgr.registerListener(_model.ringMgr, RingManager.POINT_SCORED, ringPointScored);

        // TODO: listen for turn changed and enforce the maximum turn time.
    }

    protected function gameStarted (event :StateChangedEvent) :void
    {
        _model.ringMgr.createRings();
        _model.turnMgr.assignPlayers();
        _model.turnMgr.advanceTurn();
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.isFromServer()) {
            log.warning(
                "Message received is from the server?", "name", event.name, "value", event.value);
            return;
        }

        if (event.name == RingManager.RING_ROTATION) {
            if (event.senderId != _model.turnMgr.turnHolderId) {
                log.warning("Received ring rotation request from non-turn holder!", "sender", 
                    event.senderId, "turnHolder", _model.turnMgr.turnHolderId);
                return;
            }

            _model.ringMgr.rotateRing(
                event.value.ring, RotationDirection.valueOf(event.value.direction));
            var timer :Timer = new Timer(TurnManager.TURN_ANIMATION_TIME, 1);
            _eventMgr.registerOneShotCallback(timer, TimerEvent.TIMER, function () :void {
                _model.turnMgr.advanceTurn();
            });
            timer.start();
        }
    }

    protected function ringPointScored (event :ValueEvent) :void
    {
        // this is coming from a source we trust - we just need to send it along to the appropriate
        // manager
        _model.scoreMgr.playerScoredPoint(event.value as Player);
    }

    private static const log :Log = Log.getLog(ServerLocksmithController);
}
}
