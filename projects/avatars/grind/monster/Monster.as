//
// $Id$

package {

import flash.events.Event;
import flash.events.TimerEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import flash.media.Sound;

import com.whirled.PetControl;
import com.whirled.ControlEvent;

[SWF(width="128", height="250")]
public class Monster_@MONSTER_NAME@ extends Sprite
{
    public function Monster_@MONSTER_NAME@ ()
    {
        trace("@MONSTER_NAME@ : I am level " + @MONSTER_LEVEL@);
        _ctrl = new PetControl(this);

        _ctrl.registerPropertyProvider(propertyProvider);

        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemory);
        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleMovement);

        _ghost = Bitmap(new GHOST());
        _ghost.smoothing = true;

        _image = Bitmap(new IMAGE());
        _image.smoothing = true;

        _quest = new QuestSprite(_ctrl);
        addChild(_quest);

        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.setTickInterval(9000);

        handleMemory();
    }

    public function tick (event :TimerEvent) :void
    {
        var targets :Array = QuestUtil.query(_ctrl, function (svc :Object) :Boolean {
            return svc.getType() == QuestConstants.TYPE_PLAYER &&
                QuestUtil.squareDistanceTo(_ctrl, svc.getIdent()) < 1000*1000;
        });

        _hunting = targets[int(Math.random()*targets.length)];

        if (_quest.getHealth()/_quest.getMaxHealth() < 0.25) {
            _ctrl.setState(QuestConstants.STATE_HEAL);
        } else {
            _ctrl.setState([QuestConstants.STATE_ATTACK, QuestConstants.STATE_COUNTER]
                    [int(Math.random()*2)]);
        }

        var here :Array = _ctrl.getLogicalLocation();
        var move :Array = [Math.random(), 0, Math.random()];
        var angle :Number = Math.atan2(move[2]-here[2], move[0]-here[0]); // Radians
        angle = (360 + 90 + Math.round(180/Math.PI * angle)) % 360; // Convert to our degree system

        _ctrl.setLogicalLocation(move[0], move[1], move[2], angle);
    }

    public function handleMovement (event :ControlEvent) :void
    {
        if (event.name == _hunting) {
        }
    }

    protected function handleMemory (... _) :void
    {
        if (_quest.getHealth() == 0) {
            _quest.setActor(_ghost);
        } else {
            _quest.setActor(_image);
        }
    }

    protected function handleMessage (event :ControlEvent) :void
    {
        if (event.name == "effect") {
            var effect :Object = event.value;

            if ("event" in effect) {
                switch (effect.event) {
                    case QuestConstants.EVENT_ATTACK:
                        _soundAttack.play();
                        break;

                    case QuestConstants.EVENT_COUNTER:
                        //_soundCounter.play();
                        break;

                    case QuestConstants.EVENT_HEAL:
                        //_soundHeal.play();
                        break;

                    case QuestConstants.EVENT_DIE:
                        _soundDeath.play();
                        break;
                }
            }
        }
    }

    public function propertyProvider (key :String) :Object
    {
        if (key == QuestConstants.SERVICE_KEY) {
            return _svc;
        } else {
            return null;
        }
    }

    protected var _ctrl :PetControl;

    protected var _quest :QuestSprite;

    [Embed(source="ghost.png")]
    protected static const GHOST :Class;
    protected var _ghost :Bitmap;

    [Embed(source="rsrc/@MONSTER_NAME@.png")]
    protected static const IMAGE :Class;
    protected var _image :Bitmap;

    [Embed(source="rsrc/@SOUND_ATTACK@")]
    protected static const SOUND_ATTACK :Class;
    protected var _soundAttack :Sound = new SOUND_ATTACK() as Sound;

    [Embed(source="rsrc/@SOUND_DEATH@")]
    protected static const SOUND_DEATH :Class;
    protected var _soundDeath :Sound = new SOUND_DEATH() as Sound;

    // Who I'm hunting. WARNING: This isn't preserved
    protected var _hunting :String;

    // Bye bye type checking
    protected const _svc :Object = {
        getState: function () :String {
            return (_quest.getHealth() == 0) ? QuestConstants.STATE_DEAD : _ctrl.getState();
        },

        getIdent: function () :String {
            return _ctrl.getMyEntityId();
        },

        getType: function () :String {
            return QuestConstants.TYPE_MONSTER;
        },

        getPower: function () :Number {
            return _quest.getLevel()*5;
        },

        getDefence: function () :Number {
            return 0;
        },

        getRange: function () :Number {
            return 400;
        },

        getLevel: function () :int {
            return _quest.getLevel();
        },

        awardRandomItem: function (level :int) :void {
        },

        awardXP: function (amount :int) :void {
            // Sure, monsters can level up
            _ctrl.setMemory("xp", int(_ctrl.getMemory("xp")) + amount);
        },

        revive: function () :void {
            _ctrl.setMemory("health", _quest.getMaxHealth());
        },

        damage: function (
            source :Object, amount :int, cause :Object = null, ignoreArmor :Boolean = false) :void {
            _quest.damage(source, amount, cause, ignoreArmor);
        }
    };
}
}
