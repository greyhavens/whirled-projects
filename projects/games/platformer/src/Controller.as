//
// $Id$

package {

import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.whirled.game.GameControl;

import board.Board;

import display.BoardSprite;
import display.PieceSpriteFactory;
import display.Metrics;

import piece.Piece;
import piece.PieceFactory;

public class Controller
{
    /** Some useful key codes. */
    public static const KV_LEFT :uint = 37;
    public static const KV_UP :uint = 38;
    public static const KV_RIGHT :uint = 39;
    public static const KV_DOWN : uint = 40;

    public static const KV_A :uint = 65;
    public static const KV_B :uint = 66;
    public static const KV_C :uint = 67;
    public static const KV_D :uint = 68;
    public static const KV_E :uint = 69;
    public static const KV_F :uint = 70;
    public static const KV_G :uint = 71;
    public static const KV_H :uint = 72;
    public static const KV_I :uint = 73;
    public static const KV_J :uint = 74;
    public static const KV_K :uint = 75;
    public static const KV_L :uint = 76;
    public static const KV_M :uint = 77;
    public static const KV_N :uint = 78;
    public static const KV_O :uint = 79;
    public static const KV_P :uint = 80;
    public static const KV_Q :uint = 81;
    public static const KV_R :uint = 82;
    public static const KV_S :uint = 83;
    public static const KV_T :uint = 84;
    public static const KV_U :uint = 85;
    public static const KV_V :uint = 86;
    public static const KV_W :uint = 87;
    public static const KV_X :uint = 88;
    public static const KV_Y :uint = 89;
    public static const KV_Z :uint = 90;

    public function Controller (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _board = new Board();
        _boardSprite = new BoardSprite(_board, this);
        _pfac = new PieceFactory(PIECES);
    }

    public function getSprite () :BoardSprite
    {
        return _boardSprite;
    }

    public function init (onReady :Function) :void
    {
        _board.loadFromXML(LEVEL.board[0], _pfac);
        /*
        for (var xx :int = 0; xx < 500; xx++) {
            _board.addPiece(new Piece("block", xx, 0));
            _board.addPiece(new Piece("block", xx, Metrics.WINDOW_HEIGHT));
        }
        for (var yy :int = 0; yy < Metrics.WINDOW_HEIGHT; yy++) {
            _board.addPiece(new Piece("block", 0, yy));
            _board.addPiece(new Piece("block", 500, yy));
        }
        _board.addPiece(new Piece("buildings", 10, 1));
        _board.addPiece(new Piece("buildings_anim", 35, 1));
        _board.addPiece(new Piece("cactus_big", 20, 1));
        _board.addPiece(new Piece("cactus_med", 30, 1));
        _board.addPiece(new Piece("cloud", 15, 5));
        */
        PieceSpriteFactory.init(onReady);
    }

    public function run () :void
    {
        _boardSprite.initDisplay();
        _gameCtrl.local.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _gameCtrl.local.addEventListener(KeyboardEvent.KEY_UP, keyReleased);

        // start the time
        _mainTimer = new Timer(1, 0);
        _mainTimer.addEventListener(TimerEvent.TIMER, tick);
        _mainTimer.start();
        _lastTickTime = getTimer();
        _lastFrameTick = _lastTickTime;
    }

    public function feedback (message :String) :void
    {
        _gameCtrl.local.feedback(message);
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (event.keyCode == KV_UP) {
            _dy = -1;
        } else if (event.keyCode == KV_DOWN) {
            _dy = 1;
        } else if (event.keyCode == KV_LEFT) {
            _dx = -1;
        } else if (event.keyCode == KV_RIGHT) {
            _dx = 1;
        } else if (event.keyCode == KV_B) {
            _boardSprite.toggleBG();
        } else if (event.keyCode == KV_F) {
            startFrameCheck();
        }
    }

    protected function keyReleased (event :KeyboardEvent) :void
    {
        if (event.keyCode == KV_UP) {
            if (_dy == -1) {
                _dy = 0;
            }
        } else if (event.keyCode == KV_DOWN) {
            if (_dy == 1) {
                _dy = 0;
            }
        } else if (event.keyCode == KV_LEFT) {
            if (_dx == -1) {
                _dx = 0;
            }
        } else if (event.keyCode == KV_RIGHT) {
            if (_dx == 1) {
                _dx = 0;
            }
        }
    }

    protected function startFrameCheck () :void
    {
        _mainTimer.stop();
        _mainTimer.removeEventListener(TimerEvent.TIMER, tick);
        _boardSprite.centerOn(0, 0);
        _mainTimer.addEventListener(TimerEvent.TIMER, frametick);
        _mainTimer.start();
        _lastTickTime = getTimer();
        _lastFrameTick = _lastTickTime;
        _frames = 0;
    }

    protected function frametick (event :TimerEvent) :void
    {
        var now :int = getTimer();
        _frames++;
        var delta :int = now - _lastFrameTick;
        if (delta < 5000) {
            _boardSprite.centerOn(delta/10, 0);
        } else if (delta < 6000) {
            _boardSprite.centerOn(delta/10, (delta - 5000)/10);
        } else if (delta < 7000) {
            _boardSprite.centerOn(600 - (7000 - delta)/10, (delta - 5000)/10);
        } else if (delta < 10000) {
            _boardSprite.centerOn(600 - (10000 - delta)/10, 200);
        } else if (delta < 11000) {
            _boardSprite.centerOn((10000 - delta)/10, 200 - (10000 - delta)/10);
        } else if (delta < 15000) {
            _boardSprite.centerOn((10000 - delta)/10, 100);
        }


        if (now - _lastFrameTick > FRAME_CHECK) {
            _gameCtrl.local.feedback("Frame Rate: " + (_frames  / (FRAME_CHECK / 1000)));
            _mainTimer.stop();
            _mainTimer.removeEventListener(TimerEvent.TIMER, frametick);
            _mainTimer.addEventListener(TimerEvent.TIMER, tick);
            _mainTimer.start();
            _lastTickTime = getTimer();
            _lastFrameTick = _lastTickTime;
            _frames = 0;
       }
    }

    protected function tick (event :TimerEvent) :void
    {
        var now :int = getTimer();
        var tickDelta :int = now - _lastTickTime;
        var secDelta :Number = tickDelta / 1000;
        var dX :Number = 100 * _dx * secDelta;
        var dY :Number = 100 * _dy * secDelta;
        _frames++;
        _boardSprite.moveDelta(dX, dY);
        _lastTickTime = now;
        if (_lastTickTime - _lastFrameTick > FRAME_OUT) {
            _gameCtrl.local.feedback("Frame Rate: " + (_frames  / 5));
            _frames = 0;
            _lastFrameTick = _lastTickTime;
        }
    }

    protected var _dx :int;
    protected var _dy :int;

    protected var _board :Board;
    protected var _boardSprite :BoardSprite;

    protected var _pfac :PieceFactory;

    protected var _gameCtrl :GameControl;

    protected var _mainTimer :Timer;
    protected var _lastTickTime :int;

    protected static const FRAME_OUT :int = 5000;
    protected static const FRAME_CHECK :int = 15000;
    protected var _frames :int;
    protected var _lastFrameTick :int;

    include "../rsrc/level.xml";

    include "../rsrc/pieces.xml";
}
}
