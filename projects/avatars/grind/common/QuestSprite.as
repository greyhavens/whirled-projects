//
// $Id$

package {

import flash.events.Event;
import flash.events.TimerEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import flash.utils.getTimer; // function import
import flash.utils.Timer;

import com.threerings.flash.TextFieldUtil;

import com.whirled.EntityControl;
import com.whirled.ActorControl;
import com.whirled.ControlEvent;

import caurina.transitions.Tweener;

public class QuestSprite extends Sprite
{
    public static const MAX_HEIGHT :int = 250;

    public var bounciness :Number = 20;
    public var bounceFreq :Number = 200;
    public var right :Boolean = false;

    public function QuestSprite (ctrl :ActorControl)
    {
        _ctrl = ctrl;

        _container = new Sprite();
        _container.width = 32;
        _container.height = 32;
        _container.scaleX = 2;
        _container.scaleY = 2;

        addChild(_container);

        _xpField = TextFieldUtil.createField(name,
            { textColor: 0xffffff, selectable: false,
                autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
            { font: "_sans", size: 10, bold: true });
        _xpField.y = MAX_HEIGHT/2;
        addChild(_xpField);

        _healthBar = new HealthBar();
//        _healthBar.width = 32;
//        _healthBar.height = 4;
        addChild(_healthBar);

        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, setupVisual);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemory);
        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);

        _ctrl.setTickInterval(4000);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);

        addEventListener(Event.UNLOAD, stopBouncing);

        //_ticker = new Ticker(_ctrl, 4000, tick);
//        var timer :Timer = new Timer(4000);
//        /*root.loaderInfo.addEventListener(Event.UNLOAD, function (..._) :void {
//            timer.stop();
//        });*/
//        timer.start();

        handleMemory();
    }

    public function setActor (actor :DisplayObject) :void
    {
        if (actor != _actor) {
            if (_actor != null) {
                _container.removeChild(_actor);
            }
            _actor = actor;
            _container.addChild(_actor);

            stopBouncing();
            setupVisual();
        }
    }

    protected function tick (event :TimerEvent) :void
    {
        switch (QuestUtil.self(_ctrl).getState()) {
            case QuestConstants.STATE_ATTACK:
                attack();
                break;
            case QuestConstants.STATE_HEAL:
                QuestUtil.self(_ctrl).damage(null, -0.2*getMaxHealth(), {
                    text: "Heal",
                    event: QuestConstants.EVENT_HEAL
                }, true);
                break;
            case QuestConstants.STATE_COUNTER:
                QuestUtil.self(_ctrl).damage(null, 0.1*getMaxHealth(), {
                    text: "Concentrate...",
                    event: QuestConstants.EVENT_COUNTER
                }, true);
                break;
        }
    }

    protected function attack () :void
    {
        var self :Object = QuestUtil.self(_ctrl);
        var amount :Number = self.getPower();
        var id :String = QuestUtil.fetchClosest(_ctrl);
        var d2 :Number = QuestUtil.squareDistanceTo(_ctrl, id);

        if (id != null && d2 <= self.getRange()*self.getRange()) {
            var target :Object = QuestUtil.getService(_ctrl, id);
            if (target.getState() == QuestConstants.STATE_COUNTER &&
                d2 <= target.getRange()*target.getRange()) {

                self.damage(target, target.getPower(), {text:"Countered!"});
                target.damage(self, amount*0.25);

            } else {
                target.damage(self, amount);
            }

            effect({text:"Rawr", event:QuestConstants.EVENT_ATTACK});
        }
    }

    public function damage (source :Object, amount :Number, fx :Object, ignoreArmor :Boolean) :void
    {
        var health :Number = getHealth();
        if (health == 0) {
            return; // Don't revive
        }

        if (!ignoreArmor) {
            var defence :int = QuestUtil.self(_ctrl).getDefence();
            amount *= Math.max(0, (10 - defence)/10); // TODO: Tweak
        }

        if (amount > 0 && QuestUtil.self(_ctrl).getState() == QuestConstants.STATE_HEAL) {
            amount *= 2;
        }

        var hit :String = (amount < 0) ? "+"+(-amount) : "-"+amount;
        if (fx != null) {
            if ("text" in fx) {
                // Add the damage string to it
                fx.text = hit + " (" + fx.text + ")";
            } else {
                fx.text = hit;
            }
            // If the color isn't specified and it's a heal
            if (!("color" in fx) && amount < 0) {
                // Make it green
                fx.color = 0x00ff00;
            }
        } else {
            fx = {text: hit};
        }

        effect(fx);

        if (health <= amount) {
            _ctrl.setMemory("health", 0);
            if (source != null) {
                // Goodies
                source.awardXP(666);
                source.awardRandomItem(getLevel());
            }

            // Send the event out to the AVRG and anything else that cares
            _ctrl.sendSignal("grind:death", [
                _ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, source.getIdent()),
                getLevel() ]);

            effect({text:"Death", event:QuestConstants.EVENT_DIE});
        } else {
            _ctrl.setMemory("health", Math.min(health-amount, getMaxHealth()));
        }
    }

    protected function handleMemory (... _) :void
    {
        _xpField.text = "Level " + getLevel() + " (" + getXP() + " xp)";
        _healthBar.percent = getHealth()/getMaxHealth();
    }

    protected function handleMessage (event :ControlEvent) :void
    {
        if (event.name == "effect") {
            var effect :Object = event.value;

            // Show floaty text as part of this effect
            if ("text" in effect) {
                var field :TextField = TextFieldUtil.createField(name,
                    { textColor: ("color" in effect) ? effect.color : 0xFF4400, selectable: false,
                        autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
                    { font: "_sans", size: 12, bold: true });

                field.text = effect.text as String;
                field.y = MAX_HEIGHT - 50;

                var complete :Function = function () :void {
                    removeChild(this);
                };
                Tweener.addTween(field, {y: 50, time:2, onComplete:complete, transition:"linear"});

                addChild(field);
            }

            if ("event" in effect && effect.event == QuestConstants.EVENT_ATTACK) {
                if (_actor != null) {
                    _actor.x = 0;
                    _actor.y = 0;
                    Tweener.addTween(_actor, {
                        time: 0.1,
                        x: -10,
                        y: -4,
                        onComplete: function () :void {
                            Tweener.addTween(_actor, {
                                time: 0.5,
                                x: 0,
                                y: 0
                            });
                        }
                    });
                }
            }
        }
    }

    public function getXP () :int
    {
        return _ctrl.getMemory("xp") as Number;
    }

    public function getLevel () :int
    {
        return getXP()/100 + 1;
    }

    public function getHealth () :int
    {
        return _ctrl.getMemory("health", 1) as int;
    }

    public function getMaxHealth () :int
    {
        return getLevel()*10;
    }

    public function effect (data :Object) :void
    {
        _ctrl.sendMessage("effect", data);
    }

    public function echo (text :String, color :int = -1) :void
    {
        effect({text: text});
    }

    protected function setupVisual (... ignored) :void
    {
        var orient :Number = _ctrl.getOrientation();
        var isMoving :Boolean = _ctrl.isMoving();

        // make sure we're oriented correctly
        // (We discard nearly all the orientation information and only care if we're
        // facing left or right.)
        if (right == (orient > 180)) {
            _container.x = _container.width;
            _container.scaleX = -2;

        } else {
            _container.x = 0;
            _container.scaleX = 2;
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
        _container.y = MAX_HEIGHT - _container.height - (Math.sin(val) * bounciness);
    }

    protected function stopBouncing (... ignored) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _container.y = MAX_HEIGHT - _container.height;
    }

    protected var _ctrl :ActorControl;

    protected var _container :Sprite;

    protected var _actor :DisplayObject;

//    protected var _ticker :Ticker;

    /** Are we currently bouncing? */
    protected var _bouncing :Boolean = false;

    /** The time at which the current bounce started. */
    protected var _bounceBase :Number;

    protected var _xpField :TextField;

    protected var _healthBar :HealthBar;
}
}
