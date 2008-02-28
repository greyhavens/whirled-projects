package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.utils.getTimer; // function import

import flash.utils.Timer;

import com.whirled.game.*;

/**
 * ClickFast: A sample single-player game that demonstrates the right way to do things
 * and flow awarding.
 */
[SWF(width="700", height="500")]
public class ClickFast extends Sprite
{
    public static const WIDTH :int = 700;
    public static const HEIGHT :int = 500;

    public static const GAME_DURATION :int = 15000; // 15 seconds

    public static const EXPLOSION_FREQUENCY :int = 200; // every 200 ms

    public static const MAX_RADIUS :int = 50;
    public static const MIN_RADIUS :int = 20;

    public static const MAX_LIFETIME :int = 2000;
    public static const MIN_LIFETIME :int = 1000;

    public function ClickFast ()
    {
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        _ctrl = new GameControl(this);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);
        _ctrl.player.addEventListener(FlowAwardedEvent.FLOW_AWARDED, handleFlowAwarded);

        _timer = new Timer(EXPLOSION_FREQUENCY, 1 + (GAME_DURATION / EXPLOSION_FREQUENCY));
        _timer.addEventListener(TimerEvent.TIMER, handleTimer);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);

        // give some feedback
        _ctrl.local.feedback("Welcome to ClickFast!\n\n" +
            "The object of the game is simple: When you see an explosion start to grow, " +
            "click it as soon as possible. The quicker you click something, the more points " +
            "you'll get for it.");
    }

    public function addScore (delta :int) :void
    {
        _score += delta;
        // and display it in the player list next to the player's name.
        _ctrl.local.setPlayerScores([ _score ]);
    }

    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        _ctrl.local.feedback("GO!");

        _score = 0;
        addScore(0); // update the display...
        _timer.start();
    }

    protected function handleTimer (event :TimerEvent) :void
    {
        // add an explosion somewhere
        var xx :Number = random(0, WIDTH);
        var yy :Number = random(0, HEIGHT);
        var radius :Number = random(MIN_RADIUS, MAX_RADIUS);
        var lifetime :Number = random(MIN_LIFETIME, MAX_LIFETIME);
        addChild(new Explosion(this, xx, yy, radius, lifetime));
    }

    protected function handleTimerComplete (event :TimerEvent) :void
    {
        _timer.reset();
        // remove all unclicked explosions
        while (numChildren > 0) {
            removeChildAt(0);
        }
        // tell the server to end the game
        _ctrl.game.endGameWithScore(_score);
    }

    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _ctrl.local.feedback("Good game!");
    }

    protected function handleFlowAwarded (event :FlowAwardedEvent) :void
    {
        _ctrl.local.feedback("You earned " + event.amount + " flow!");
    }

    /**
     * Utility method to return a random number between min and max.
     */
    protected static function random (min :Number, max :Number) :Number
    {
        return min + (Math.random() * (max - min));
    }

    protected var _ctrl :GameControl;

    protected var _timer :Timer;

    protected var _score :int;
}
}

import flash.events.MouseEvent;

import flash.utils.getTimer; // function import

import com.threerings.flash.FrameSprite;

class Explosion extends FrameSprite
{
    public function Explosion (
        parent :ClickFast, xx :int, yy :int, maxRadius :Number, lifetime :Number)
    {
        super(false);

        this.x = xx;
        this.y = yy;
        _parent = parent;
        _maxRadius = maxRadius;
        _curRadius = 0;
        _lifetime = lifetime;
        addEventListener(MouseEvent.CLICK, handleClick);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        _parent.addScore(int(_maxRadius - _curRadius));
        this.parent.removeChild(this);
    }

    override protected function handleFrame (... ignored) :void
    {
        var now :Number = getTimer();
        if (isNaN(_startStamp)) {
            _startStamp = now;
        }

        var elapsed :Number = now - _startStamp;
        if (elapsed > _lifetime) {
            this.parent.removeChild(this);
            return;
        }

        _curRadius = _maxRadius * (elapsed / _lifetime);

        graphics.clear();
        graphics.beginFill(0x660000);
        graphics.drawCircle(0, 0, _curRadius);
    }

    protected var _parent :ClickFast;

    protected var _maxRadius :Number;

    protected var _lifetime :Number;

    protected var _startStamp :Number = NaN;

    protected var _curRadius :Number;
}
