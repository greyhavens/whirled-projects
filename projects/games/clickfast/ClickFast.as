package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.utils.getTimer; // function import

import flash.utils.Timer;

import com.whirled.game.*;

/**
 * ClickFast: sample single-player game.
 */
[SWF(width="700", height="500")]
public class ClickFast extends Sprite
{
    public static const WIDTH :int = 700;
    public static const HEIGHT :int = 500;

    public static const GAME_DURATION :int = 15000; // 15 seconds

    public static const NUM_PHASES :int = 3;

    public static const MAX_RADIUS :int = 50;

    public static const MAX_LIFETIME :int = 2000;

    public function ClickFast ()
    {
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        _ctrl = new GameControl(this);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);
        _ctrl.player.addEventListener(FlowAwardedEvent.FLOW_AWARDED, handleFlowAwarded);

        _timer = new Timer(1000);
        _timer.addEventListener(TimerEvent.TIMER, handleTimer);

        // give some feedback
        _ctrl.local.feedback("Welcome to ClickFast!\n\n" +
            "The object of the game is simple: When you see an explosion start to grow, " +
            "click it as soon as possible. The quicker you click something, the more points " +
            "you'll get for it.");
    }

    public function addScore (score :int) :void
    {
        _score += score;
        _ctrl.local.setPlayerScores([ _score ]);
    }

    protected function handleFlowAwarded (event :FlowAwardedEvent) :void
    {
        _ctrl.local.feedback("You earned " + event.amount + " flow!");
    }

    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        _ctrl.local.feedback("GO!");
        _startTime = getTimer();

        _phase = 0;
        _score = 0;
        addScore(0);
        _timer.delay = 200;
        _timer.start();
    }

    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _ctrl.local.feedback("Good game!");
        // TODO
    }

    protected function handleTimer (event :TimerEvent) :void
    {
        var now :Number = getTimer();
        var elapsed :Number = now - _startTime;
        if (elapsed > (GAME_DURATION / NUM_PHASES)) {
            _timer.reset();
            _phase++;
            if (_phase == NUM_PHASES) {
                while (numChildren > 0) {
                    removeChildAt(0);
                }
                _ctrl.game.endGameWithScore(_score);
                return;
            }

            _timer.delay /= 2;
            _timer.start();
            _startTime = now;
        }

        // then, add an explosion somewhere
        var xx :Number = Math.random() * WIDTH;
        var yy :Number = Math.random() * HEIGHT;
        var radius :Number = Math.random() * MAX_RADIUS;
        var lifetime :Number = Math.random() * MAX_LIFETIME;
        addChild(new Explosion(this, xx, yy, radius, lifetime));
    }

    protected var _ctrl :GameControl;

    protected var _timer :Timer;

    protected var _score :int;

    protected var _phase :int;

    protected var _startTime :Number;
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
