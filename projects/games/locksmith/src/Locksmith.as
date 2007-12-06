// $Id$

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.IEventDispatcher;

import flash.ui.Keyboard;

import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

import com.threerings.util.ArrayUtil;

import com.whirled.FlowAwardedEvent;
import com.whirled.WhirledGameControl;

import com.whirled.contrib.EventHandlers;

[SWF(width="700", height="500")]
public class Locksmith extends Sprite
{
    public static const DISPLAY_WIDTH :int = 700;
    public static const DISPLAY_HEIGHT :int = 500;

    public static const NUM_RINGS :int = 4;
    public static const RING_POSITIONS :int = 16;

    public static const WIN_SCORE :int = 6;

    public function Locksmith ()
    {
        EventHandlers.registerUnload(root.loaderInfo);

        addChild(_board = new Board());
        // centering the board display makes all placement and animation *a lot* easier for this 
        // game
        _board.x = DISPLAY_WIDTH / 2;
        _board.y = DISPLAY_HEIGHT / 2;
        _control = new WhirledGameControl(this);
        if (_control.isConnected()) {
            EventHandlers.registerEventListener(
                _control, StateChangedEvent.GAME_STARTED, gameDidStart);
            EventHandlers.registerEventListener(
                _control, StateChangedEvent.GAME_ENDED, gameDidEnd);
            EventHandlers.registerEventListener(
                _control, StateChangedEvent.TURN_CHANGED, turnDidChange);
            EventHandlers.registerEventListener(
                _control, MessageReceivedEvent.TYPE, messageReceived);
            EventHandlers.registerEventListener(_control, KeyboardEvent.KEY_DOWN, keyDownHandler);
            EventHandlers.registerEventListener(_control, FlowAwardedEvent.FLOW_AWARDED, 
                function (event :FlowAwardedEvent) :void {
                    _control.localChat("You were awarded " + event.amount + " flow!");
                });
            _board.control = _control;
        } else {
            // show some rings so there is something visible when the game is not connected
            var ringData: Array = createRings();
            for (var ring :int = 0; ring < NUM_RINGS; ring++) {
                _board.addRing(new Ring(ring + 1, ringData[ring]));
            }
        }
    }

    public function gameDidStart (event :StateChangedEvent) :void
    {
        var playerIds :Array = _control.seating.getPlayerIds();
        addChild(_scoreBoard = new ScoreBoard(
            _control.getOccupantName(_moonPlayer = playerIds[0]), 
            _control.getOccupantName(_sunPlayer = playerIds[1]), 
            endGame));
        _scoreBoard.x = DISPLAY_WIDTH / 2;
        _scoreBoard.y = DISPLAY_HEIGHT / 2;
        _board.scoreBoard = _scoreBoard;
        if (_control.amInControl()) {
            _control.startNextTurn();
            _control.sendMessage("newRings", createRings());
        }
    }

    public function gameDidEnd (event :StateChangedEvent) :void
    {
        _board.stopRotation();
        _gameIsOver = true;
        _control.localChat("Game Over!");
        if (_scoreBoard.moonScore >= WIN_SCORE && _scoreBoard.sunScore >= WIN_SCORE) {
            _control.localChat("The game is a tie!");
        } else if (_scoreBoard.moonScore >= WIN_SCORE) {
            _control.localChat(_control.getOccupantName(_moonPlayer) + " is the Winner!");
        } else if (_scoreBoard.sunScore >= WIN_SCORE) {
            _control.localChat(_control.getOccupantName(_sunPlayer) + " is the Winner!");
        }
    }

    public function turnDidChange (event :StateChangedEvent) :void
    {
        if (_currentRing != null && !_gameIsOver) {
            _board.clock.turnOver();
            _board.setActiveRing(-1);
            var newTurn :Function = function (...ignored) :void {
                _board.clock.newTurn();
                if (_control.isMyTurn()) {
                    _board.setActiveRing(_currentRing.num);
                }
                _board.updateTurnIndicator(_control.getTurnHolder() == _moonPlayer ? 
                    ScoreBoard.MOON_PLAYER : ScoreBoard.SUN_PLAYER);
                _board.loadNextLauncher();
            }
            DoLater.instance.registerAt(DoLater.ROTATION_AFTER_END, newTurn);
            if (DoLater.instance.mostRecentStage == DoLater.ROTATION_AFTER_END) {
                // assume that this turn timed out, and trigger ROTATION_AFTER_END again
                DoLater.instance.trigger(DoLater.ROTATION_END);
                DoLater.instance.trigger(DoLater.ROTATION_AFTER_END);
            }
        }
    }

    public function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == "newRings") {
            var ringData :Array = event.value as Array;
            for (var ii :int = 0; ii < ringData.length; ii++) {
                var ring :Ring = new Ring(ii + 1, ringData[ii]);
                _board.addRing(ring);
                if (ii != 0) {
                    ring.inner = _currentRing;
                    _currentRing.outer = ring;
                }
                _currentRing = ring;
            }

            if (_control.isMyTurn()) {
                _board.setActiveRing(_currentRing.num);
            }
            _board.loadNextLauncher();
        } else if (event.name == "ringRotation") {
            ring = _currentRing.smallest;
            while (ring.num != event.value.ring) {
                ring = ring.outer;
            }
            ring.rotate(event.value.direction);
        }
    }

    protected function endGame () :void
    {
        DoLater.instance.finishAndCall(function () :void {
            _board.stopRotation();
            if (_control.amInControl()) {
                var winners :Array = [];
                if (_scoreBoard.sunScore >= WIN_SCORE) {
                    winners.push(_sunPlayer);
                }
                if (_scoreBoard.moonScore >= WIN_SCORE) {
                    winners.push(_moonPlayer);
                }
                _control.endGameWithScores([_sunPlayer, _moonPlayer], 
                    [Math.round((_scoreBoard.sunScore / WIN_SCORE) * 100),
                        Math.round((_scoreBoard.moonScore / WIN_SCORE) * 100)],
                    WhirledGameControl.CASCADING_PAYOUT);
            }
        });
    }

    protected function keyDownHandler (event :KeyboardEvent) :void
    {
        if (_control.isMyTurn() && !_gameIsOver) {
            switch(event.keyCode) {
            case Keyboard.LEFT:
                _control.sendMessage("ringRotation", { ring: _currentRing.num, direction: 
                    Ring.COUNTER_CLOCKWISE });
                _control.startNextTurn();
                break;
            case Keyboard.RIGHT:
                _control.sendMessage("ringRotation", { ring: _currentRing.num, direction:
                    Ring.CLOCKWISE });
                _control.startNextTurn();
                break;
            case Keyboard.UP:
                if (_currentRing != _currentRing.largest) {
                    _currentRing = _currentRing.outer;
                    _board.setActiveRing(_currentRing.num);
                }
                break;
            case Keyboard.DOWN:
                if (_currentRing != _currentRing.smallest) {
                    _currentRing = _currentRing.inner;
                    _board.setActiveRing(_currentRing.num);
                }
                break;
            }
        }
    }

    protected function createRings () :Array
    {
        var rings :Array = new Array();
        var holes :Array;
        for (var ii :int = 1; ii <= NUM_RINGS; ii++) {
            holes = new Array();
            for (var hole :int = 0; hole < (ii == 4 ? 6 : Math.pow(2, ii + 1) / 2); hole++) {
                var pos :int = 0;
                do {
                    pos = Math.floor(Math.random() * RING_POSITIONS);
                } while (pos % (ii == 4 ? 2 : RING_POSITIONS / Math.pow(2, ii + 1)) != 0 ||
                    ArrayUtil.contains(holes, pos));
                holes.push(pos);
            }
            rings.push(holes);
        }
        return rings;
    }

    protected var _board :Board;
    protected var _control :WhirledGameControl;
    protected var _currentRing :Ring;
    protected var _scoreBoard :ScoreBoard;
    protected var _moonPlayer :int;
    protected var _sunPlayer :int;
    protected var _gameIsOver :Boolean = false;
}
}
