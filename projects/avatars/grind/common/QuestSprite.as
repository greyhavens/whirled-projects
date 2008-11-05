//
// $Id$

package {

import flash.events.Event;
import flash.events.TimerEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.text.TextField;

import flash.utils.getTimer; // function import
import flash.utils.Timer;

import com.whirled.ActorControl;
import com.whirled.ControlEvent;

import caurina.transitions.Tweener;

public class QuestSprite extends Sprite
{
    public static const MAX_HEIGHT :int = 250;

    public var bounciness :Number = 1;
    public var bounceFreq :Number = 1;
    public var right :Boolean = false;

    public function QuestSprite (ctrl :ActorControl, actor :DisplayObject)
    {
        _ctrl = ctrl;

        _actor = actor;
        addChild(_actor);

        _xpField.y = MAX_HEIGHT/2;
        addChild(_xpField);

//        _healthBar.width = 32;//_actor.width;
//        _healthBar.height = 8;
        addChild(_healthBar);

        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, setupVisual);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemory);

        addEventListener(Event.UNLOAD, stopBouncing);
        stopBouncing();

        //_ticker = new Ticker(_ctrl, 4000, tick);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.setTickInterval(4000);

//        var timer :Timer = new Timer(4000);
//        timer.addEventListener(TimerEvent.TIMER, tick);
//        /*root.loaderInfo.addEventListener(Event.UNLOAD, function (..._) :void {
//            timer.stop();
//        });*/
//        timer.start();

        _ctrl.requestControl();
        setupVisual();
        handleMemory();
    }

    protected function tick (event :TimerEvent) :void
    {
        switch (QuestUtil.self(_ctrl).getState()) {
            case QuestConstants.STATE_ATTACK:
                attack();
                break;
            case QuestConstants.STATE_HEAL:
                damage(-0.2*getMaxHealth(), "Heal");
                break;
            case QuestConstants.STATE_COUNTER:
                damage(0.1*getMaxHealth(), "Concentrate...");
                break;
        }
    }

    protected function attack () :void
    {
        trace("I see " + QuestUtil.query(_ctrl).length + " players");

        var self :Object = QuestUtil.self(_ctrl);
        var amount :Number = self.getPower();

        for each (var svc :Object in QuestUtil.fetch(_ctrl, 666, 200)) {
            if (svc.getState() == QuestConstants.STATE_COUNTER) {
                damage(svc.getPower(), "Countered!");
                svc.damage(amount*0.25);
            } else {
                svc.damage(amount);
            }
        }
    }

    public function damage (amount :Number, cause :String) :void
    {
        if (_ctrl.getMemory("health") == 0) {
            return; // Don't revive
        }

        if (amount > 0 && QuestUtil.self(_ctrl).getState() == QuestConstants.STATE_HEAL) {
            amount *= 2;
        }

        if (cause != null) {
            echo(amount + " (" + cause + ")");
        } else {
            echo(String(amount));
        }

        var health :Number = _ctrl.getMemory("health") as Number;
        if (health <= amount) {
            _ctrl.setMemory("health", 0);
            echo("DEAD"); // TODO
        } else {
            _ctrl.setMemory("health", Math.min(health-amount, getMaxHealth()));
        }
    }

    protected function handleMemory (... _) :void
    {
        //_xpField.text = String(_ctrl.getMemory("xp", 666));

        //echo("Memory " + event.name + ": " + event.value);
//        switch (event.name) {
//            case "health":
                _healthBar.percent = Number(_ctrl.getMemory("health"))/getMaxHealth();
//                break;
//        }
    }

    public function getXP () :Number
    {
        return _ctrl.getMemory("xp") as Number;
    }

    public function getLevel () :Number
    {
        return getXP()/100 + 1;
    }

    public function getMaxHealth () :Number
    {
        return getLevel()*10;
    }

    public function echo (text :String) :void
    {
        var field :TextField = new TextField();
        field.text = text;
        field.y = MAX_HEIGHT - 10;

        var complete :Function = function () :void {
            removeChild(this);
        };
        Tweener.addTween(field, {y: 50, time:1, onComplete:complete, transition:"linear"});

        addChild(field);
    }

//    protected function gotImage (disp :DisplayObject) :void
//    {
//        _image = disp;
//        _image.y = MAX_HEIGHT - _image.height;
//        addChild(_image);
//        _ctrl.setHotSpot(MAX_WIDTH / 2, MAX_HEIGHT, _image.height);
//
//        // adjust bounciness by the room for bouncing
//        bounciness *= (MAX_HEIGHT - _image.height);
//
//        // now that everything's loaded, we're ready to hear appearance changed events
//        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, setupVisual);
//
//        // very important! We can't just assume we're standing when we first start up.
//        // We could be the instance of our avatar on someone else's screen, so the person
//        // wearing the avatar could already be moving or facing any direction, etc.
//        setupVisual();
//    }

    protected function setupVisual (... ignored) :void
    {
        var orient :Number = _ctrl.getOrientation();
        var isMoving :Boolean = _ctrl.isMoving();

        // make sure we're oriented correctly
        // (We discard nearly all the orientation information and only care if we're
        // facing left or right.)
        if (right == (orient > 180)) {
            _actor.x = _actor.width;
            _actor.scaleX = -2;

        } else {
            _actor.x = 0;
            _actor.scaleX = 2;
        }

        // if we're moving, make us bounce.
        if (bounciness > 0 && _bouncing != isMoving) {
            _bouncing = isMoving;
            if (_bouncing) {
                _bounceBase = getTimer(); // note that time at which we start bouncing
                addEventListener(Event.ENTER_FRAME, handleEnterFrame);

            } else {
                stopBouncing();
            }
        }
    }

    protected function handleEnterFrame (... ignored) :void
    {
        var now :Number = getTimer();
        var elapsed :Number = now - _bounceBase;
        while (elapsed > bounceFreq) {
            elapsed -= bounceFreq;
            _bounceBase += bounceFreq; // give us less math to do next time..
        }

        var val :Number = elapsed * Math.PI / bounceFreq;
        _actor.y = MAX_HEIGHT - _actor.height - (Math.sin(val) * bounciness);
        //_actor.y = bounciness - (Math.sin(val) * bounciness);
    }

    protected function stopBouncing (... ignored) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _actor.y = MAX_HEIGHT - _actor.height;
    }

    protected var _ctrl :ActorControl;

    protected var _actor :DisplayObject;

//    protected var _ticker :Ticker;

    /** Are we currently bouncing? */
    protected var _bouncing :Boolean = false;

    /** The time at which the current bounce started. */
    protected var _bounceBase :Number;

    protected var _xpField :TextField = new TextField();

    protected var _healthBar :HealthBar = new HealthBar();
}
}
