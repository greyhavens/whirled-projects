//
// $Id$

package {

import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.whirled.game.GameControl;

import com.threerings.util.KeyboardCodes;

import board.Board;

import display.BoardSprite;
import display.PieceSpriteFactory;
import display.Metrics;

import piece.Piece;
import piece.PieceFactory;

public class Controller
{
    public function Controller (gameCtrl :GameControl)
    {
        var piecesBytes :ByteArray = new piecesXML();
        var pieces :XML = new XML(piecesBytes.readMultiByte(piecesBytes.length, "iso-8859-1"));
        _gameCtrl = gameCtrl;
        _pfac = new PieceFactory(pieces);
        _board = new Board();
        _boardSprite = new BoardSprite(_board, this);
    }

    public function getSprite () :BoardSprite
    {
        return _boardSprite;
    }

    public function init (onReady :Function) :void
    {
        var levelBytes :ByteArray = new levelXML();
        var level :XML = new XML(levelBytes.readMultiByte(levelBytes.length, "iso-8859-1"));
        _board.loadFromXML(level, _pfac);
        PieceSpriteFactory.init(new piecesSWF(), onReady);
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
        if (event.keyCode == KeyboardCodes.UP) {
            _dy = -1;
        } else if (event.keyCode == KeyboardCodes.DOWN) {
            _dy = 1;
        } else if (event.keyCode == KeyboardCodes.LEFT) {
            _dx = -1;
        } else if (event.keyCode == KeyboardCodes.RIGHT) {
            _dx = 1;
        } else if (event.keyCode == KeyboardCodes.B) {
            _boardSprite.toggleBG();
        } else if (event.keyCode == KeyboardCodes.F) {
            startFrameCheck();
        }
    }

    protected function keyReleased (event :KeyboardEvent) :void
    {
        if (event.keyCode == KeyboardCodes.UP) {
            if (_dy == -1) {
                _dy = 0;
            }
        } else if (event.keyCode == KeyboardCodes.DOWN) {
            if (_dy == 1) {
                _dy = 0;
            }
        } else if (event.keyCode == KeyboardCodes.LEFT) {
            if (_dx == -1) {
                _dx = 0;
            }
        } else if (event.keyCode == KeyboardCodes.RIGHT) {
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

    [Embed(source="../rsrc/level1_1.xml", mimeType="application/octet-stream")]
    protected var levelXML :Class;

    [Embed(source="../rsrc/pieces.xml", mimeType="application/octet-stream")]
    protected var piecesXML :Class;

    [Embed(source="../rsrc/pieces_frontier_town2.swf", mimeType="application/octet-stream")]
    protected var piecesSWF :Class;
}
}
