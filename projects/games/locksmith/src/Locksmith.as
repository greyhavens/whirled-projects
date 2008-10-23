// $Id$

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.IEventDispatcher;

import flash.ui.Keyboard;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;

import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.GameSubControl;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.game.SizeChangedEvent;
import com.whirled.game.StateChangedEvent;

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
        _wgc = new GameControl(this);
        if (_wgc.game.isConnected()) {
            EventHandlers.registerListener(
                _wgc.game, StateChangedEvent.GAME_STARTED, gameStarted);
            EventHandlers.registerListener(
                _wgc.game, StateChangedEvent.GAME_ENDED, gameEnded);
            EventHandlers.registerListener(
                _wgc.game, StateChangedEvent.TURN_CHANGED, turnChanged);
            EventHandlers.registerListener(
                _wgc.net, MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            EventHandlers.registerListener(
                _wgc.net, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
            EventHandlers.registerListener(_wgc.local, KeyboardEvent.KEY_DOWN, keyDownHandler);
            EventHandlers.registerListener(_wgc.player, CoinsAwardedEvent.COINS_AWARDED, 
                function (event :CoinsAwardedEvent) :void {
                    log.debug("coins award [" + event.amount + "]");
                    _wgc.net.setAt(COINS_AWARD, _wgc.game.seating.getMyPosition(), event.amount);
                });
            _board.control = _wgc;

            addChildAt(_leftBackground = new BACKGROUND() as Sprite, 0);
            addChildAt(_rightBackground = new BACKGROUND() as Sprite, 0);
            _leftBackground.width = Math.max(0, (_wgc.local.getSize().x - DISPLAY_WIDTH) / 2) + 1;
            _board.x = DISPLAY_WIDTH / 2 + _leftBackground.width - 0.5;
            _rightBackground.width = _leftBackground.width;
            _rightBackground.x = _leftBackground.width + DISPLAY_WIDTH - 1;
            EventHandlers.registerListener(
                _wgc.local, SizeChangedEvent.SIZE_CHANGED, updateBackgrounds);

            // TODO: fix rematching
            _wgc.local.setShowReplay(false);
        } else {
            // show some rings so there is something visible when the game is not connected
            var ringData: Array = createRings();
            for (var ring :int = 0; ring < NUM_RINGS; ring++) {
                _board.addRing(new Ring(ring + 1, ringData[ring]));
            }
        }
    }

    public function gameStarted (event :StateChangedEvent) :void
    {
        _gotRotation = false;
        _gameEnded = false;
        // this seems backwards, but we don't really consider the game started until the first
        // turn has started.
        _gameStarted = false;
        if (_scoreBoard == null) {
            addChild(_scoreBoard = new ScoreBoard(_wgc, endGame));
            _scoreBoard.x = _board.x;
            _scoreBoard.y = DISPLAY_HEIGHT / 2;
            _board.scoreBoard = _scoreBoard;
        } else {
            // rematching... just clear out the current score, etc
            _scoreBoard.reinit();
            _board.reinit();
            _board.clock.reinit();
            DoLater.instance.flush();
        }
        if (_wgc.game.amInControl()) {
            _wgc.net.sendMessage(NEW_RINGS, createRings());
            _wgc.game.startNextTurn();
            _wgc.net.set(COINS_AWARD, [-1, -1]);
        }
    }

    public function gameEnded (event :StateChangedEvent) :void
    {
        _gameEnded = true;
    }

    public function turnChanged (event :StateChangedEvent) :void
    {
        if (_wgc.game.getTurnHolderId() == 0) {
            // spurious event at the beginning of the game
            return;
        }

        if (_gameEnded) {
            return;
        }

        if (_gameStarted) {
            var newTurn :Function = function (...ignored) :void {
                _board.setActiveRing(-1);
                _board.clock.newTurn();
                if (_wgc.game.isMyTurn()) {
                    _board.setActiveRing(_currentRing.num);
                }
                _board.updateTurnIndicator(_wgc.game.seating.getPlayerPosition(
                    _wgc.game.getTurnHolderId()));
                _board.loadNextLauncher();
            }
            if (!_gotRotation || DoLater.instance.mostRecentStage != DoLater.ROTATION_AFTER_END) {
                DoLater.instance.registerAt(DoLater.ROTATION_AFTER_END, newTurn);
                if (!_gotRotation) {
                    // player didn't make his move fast enough, so there was no rotation...  this
                    // is cleanup
                    DoLater.instance.trigger(DoLater.ROTATION_END);
                    DoLater.instance.trigger(DoLater.ROTATION_AFTER_END);
                }
            } else {
                newTurn();
            }
            _gotRotation = false;
        } else {
            // this is the first turn
            _gameStarted = true;
            _board.clock.newTurn();
            if (_wgc.game.isMyTurn()) {
                _board.setActiveRing(_currentRing.num);
            }
            _board.updateTurnIndicator(_wgc.game.seating.getPlayerPosition(
                _wgc.game.getTurnHolderId()));
            _board.loadNextLauncher();
        }
    }

    public function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == NEW_RINGS) {
            var ringData :Array = event.value as Array;
            for (var ii :int = 0; ii < ringData.length; ii++) {
                var ring :Ring = new Ring(ii + 1, ringData[ii], _board.clock);
                _board.addRing(ring);
                if (ii != 0) {
                    ring.inner = _currentRing;
                    _currentRing.outer = ring;
                }
                _currentRing = ring;
            }
        } else if (event.name == RING_ROTATION) {
            _gotRotation = true;
            _board.clock.turnOver();
            _board.setActiveRing(-1);
            DoLater.instance.registerAt(DoLater.ROTATION_AFTER_END, function (...ignored) :void {
                if (_wgc.game.isMyTurn() && _gotRotation) {
                    _wgc.game.startNextTurn();
                }
            });
            ring = _currentRing.smallest;
            while (ring.num != event.value.ring) {
                ring = ring.outer;
            }
            ring.rotate(event.value.direction);
        } else if (event.name == WINNER) {
            var winner :int = event.value as int;
            if (winner == -1) {
                _wgc.local.feedback("Game over - the game is a tie!");
            } else {
                _wgc.local.feedback("Game over - " + _wgc.game.seating.getPlayerNames()[winner] + 
                    " is the Winner!");
                _scoreBoard.displayVictory(winner);
            }
        }
    }

    protected function elementChanged (event :ElementChangedEvent) :void
    {
        switch (event.name) {
        case COINS_AWARD:
            var moonCoins :int = _wgc.net.get(COINS_AWARD)[ScoreBoard.MOON_PLAYER] as int;
            var sunCoins :int = _wgc.net.get(COINS_AWARD)[ScoreBoard.SUN_PLAYER] as int;
            if (moonCoins == -1 || sunCoins == -1) {
                break;
            }
            
            var digits :int = 1;
            while (Math.pow(10, digits) <= moonCoins || Math.pow(10, digits) <= sunCoins) {
                digits++;
            }
            _scoreBoard.displayCoins(ScoreBoard.MOON_PLAYER, moonCoins, digits);
            _scoreBoard.displayCoins(ScoreBoard.SUN_PLAYER, sunCoins, digits);
            break;
        }
    }

    protected function updateBackgrounds (event :SizeChangedEvent) :void
    {
        _leftBackground.width = Math.max(0, (_wgc.local.getSize().x - DISPLAY_WIDTH) / 2) + 1;
        _board.x = DISPLAY_WIDTH / 2 + _leftBackground.width - 0.5;
        if (_scoreBoard != null) {
            _scoreBoard.x = _board.x;
        }
        _rightBackground.width = _leftBackground.width;
        _rightBackground.x = _leftBackground.width + DISPLAY_WIDTH - 1;
    }

    protected function endGame () :void
    {
        DoLater.instance.finishAndCall(function () :void {
            _board.stopRotation();
            if (_wgc.game.amInControl()) {
                var scores :Array = [];
                scores[ScoreBoard.MOON_PLAYER] = 
                    Math.round((_scoreBoard.moonScore / WIN_SCORE) * 100);
                scores[ScoreBoard.SUN_PLAYER] =
                    Math.round((_scoreBoard.sunScore / WIN_SCORE) * 100);
                _wgc.game.endGameWithScores(_wgc.game.seating.getPlayerIds(), scores,
                    GameSubControl.TO_EACH_THEIR_OWN);
                var winner :int = scores[0] == scores[1] ? -1 : 
                    (scores[0] > scores[1] ? ScoreBoard.MOON_PLAYER : ScoreBoard.SUN_PLAYER);
                _wgc.net.sendMessage(WINNER, winner);
            }
        });
    }

    protected function keyDownHandler (event :KeyboardEvent) :void
    {
        if (_wgc.game.isMyTurn() && !_gotRotation && !_gameEnded) {
            switch(event.keyCode) {
            case Keyboard.LEFT:
                _gotRotation = true;
                _wgc.net.sendMessage(RING_ROTATION, { ring: _currentRing.num, direction: 
                    Ring.COUNTER_CLOCKWISE });
                break;
            case Keyboard.RIGHT:
                _gotRotation = true;
                _wgc.net.sendMessage(RING_ROTATION, { ring: _currentRing.num, direction:
                    Ring.CLOCKWISE });
                break;
            case Keyboard.UP:
                if (_currentRing != _currentRing.largest) {
                    _board.setActiveRing((_currentRing = _currentRing.outer).num);
                }
                break;
            case Keyboard.DOWN:
                if (_currentRing != _currentRing.smallest) {
                    _board.setActiveRing((_currentRing = _currentRing.inner).num);
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

    private static const log :Log = Log.getLog(Locksmith);

    [Embed(source="../rsrc/fill_image.png",
        scaleGridTop="28", scaleGridBottom="470", scaleGridLeft="28", scaleGridRight="285")]
    protected static const BACKGROUND :Class;

    protected static const NEW_RINGS :String = "newRings";
    protected static const RING_ROTATION :String = "ringRotation";
    protected static const WINNER :String = "winner";
    protected static const COINS_AWARD :String = "coinsAward";

    protected var _wgc :GameControl;
    protected var _board :Board;
    protected var _currentRing :Ring;
    protected var _scoreBoard :ScoreBoard;
    protected var _gameEnded :Boolean = false;
    protected var _gameStarted :Boolean = false;
    protected var _leftBackground :Sprite;
    protected var _rightBackground :Sprite;
    protected var _gotRotation :Boolean = false;
}
}
