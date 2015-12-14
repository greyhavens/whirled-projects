package {

import flash.display.Sprite;

import flash.events.TimerEvent;

import flash.geom.Rectangle;

import flash.utils.Timer;
import flash.utils.getTimer;

import com.threerings.ezgame.EZGameControl;
import com.threerings.ezgame.MessageReceivedEvent;

public class Board extends Sprite
{
    /** The color of the background. */
    public static const BACKGROUND_COLOR :int = 0x000000;
    
    public function Board (gameCtrl :EZGameControl)
    {
        _gameCtrl = gameCtrl;
        
        // draw the background
        graphics.beginFill(BACKGROUND_COLOR);
        graphics.drawRect(0, 0, 300, 400);
        
        // clip everything against the board boundaries
        scrollRect = new Rectangle(0, 0, 300, 400);
        
        // add the paddle and ball objects (which will respond to UI and
        // network events)
        addChild(_bricks = new Bricks(gameCtrl, this));
        addChild(_ownPaddle = new Paddle(gameCtrl, this, true, OWN_COLOR));
        addChild(_oppPaddle = new Paddle(gameCtrl, this, false, OPP_COLOR));
        addChild(_ownBall = new Ball(gameCtrl, this, true, OWN_COLOR));
        addChild(_oppBall = new Ball(gameCtrl, this, false, OPP_COLOR));
        
        // subscribe for pings and pongs
        _gameCtrl.addEventListener(MessageReceivedEvent.TYPE,
            messageReceivedHandler);
        
        // create the ping timer
        var timer :Timer = new Timer(PING_DELAY);
        timer.addEventListener(TimerEvent.TIMER, timerHandler);
        timer.start();
    }

    public function get ownPaddle () :Paddle
    {
        return _ownPaddle;
    }
    
    public function get oppPaddle () :Paddle
    {
        return _oppPaddle;
    }
    
    public function get bricks () :Bricks
    {
        return _bricks;
    }
    
    public function get latency () :int
    {
        return _latency;
    }
    
    protected function timerHandler (event :TimerEvent) :void
    {
        _gameCtrl.sendMessage(PING, getTimer(), 1 - _gameCtrl.seating.getMyPosition());
    }
    
    protected function messageReceivedHandler (
        event :MessageReceivedEvent) :void
    {
        if (event.name == PING) {
            _gameCtrl.sendMessage(PONG, event.value, 1 - _gameCtrl.seating.getMyPosition());
        } else if (event.name == PONG) {
            var delay :int = (getTimer() - int(event.value)) / 2;
            if (_latency == 0) {
                _latency = delay;
            } else {
                _latency = (_latency * 7 + delay) / 8;
            }
        }
    }
    
    protected var _gameCtrl :EZGameControl;
    
    /** The paddles, balls, and bricks on the board. */
    protected var _ownPaddle :Paddle, _oppPaddle :Paddle;
    protected var _ownBall :Ball, _oppBall :Ball;
    protected var _bricks :Bricks;
    
    /** The current latency estimate. */
    protected var _latency :int;
    
    /** Colors used for our own and for opponents' paddles. */
    protected static const OWN_COLOR :uint = 0x00FFFF,
        OPP_COLOR :uint = 0xFFFF00;
        
    /** Messages used to measure communication latency. */
    protected static const PING :String = "ping",
        PONG :String = "pong";
    
    /** The delay between pings. */
    protected static const PING_DELAY :int = 5000;
}
}
