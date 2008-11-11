//
// $Id$

package {

import flash.events.Event;
import flash.events.TimerEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import com.whirled.PetControl;
import com.whirled.ControlEvent;

[SWF(width="128", height="250")]
public class Monster extends Sprite
{
    public function Monster ()
    {
        _ctrl = new PetControl(this);

        _ctrl.registerPropertyProvider(propertyProvider);

        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemory);
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleMovement);

        _ghost = Bitmap(new GHOST());
        _ghost.smoothing = true;

        _image = Bitmap(new IMAGE());
        _image.smoothing = true;

        _quest = new QuestSprite(_ctrl);
        addChild(_quest);

        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.setTickInterval(9000);

        _ctrl.requestControl();

        handleMemory();
    }

    public function tick (event :TimerEvent) :void
    {
        var targets :Array = QuestUtil.query(_ctrl, function (id :String, svc :Object) {
            return svc.getType() == QuestConstants.TYPE_PLAYER &&
                QuestUtil.squareDistanceTo(_ctrl, id) < 1000*1000;
        });

        _hunting = targets[int(Math.random()*targets.length)];

        if (_quest.getHealth()/_quest.getMaxHealth() < 0.25) {
            _ctrl.setState(QuestConstants.STATE_HEAL);
        } else {
            _ctrl.setState([QuestConstants.STATE_ATTACK, QuestConstants.STATE_COUNTER]
                    [int(Math.random()*2)]);
        }

        _ctrl.setLogicalLocation(Math.random(), 0, Math.random(), 0);
    }

    public function handleMovement (event :ControlEvent) :void
    {
        if (event.name == _hunting) {
        }
    }

    public function handleMemory (... _) :void
    {
        if (_quest.getHealth() == 0) {
            _quest.setActor(_ghost);
        } else {
            _quest.setActor(_image);
        }
    }

    public function propertyProvider (key :String) :Object
    {
        if (key == QuestConstants.SERVICE) {
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

    [Embed(source="monster.png")]
    protected static const IMAGE :Class;
    protected var _image :Bitmap;

    // Who I'm hunting. WARNING: This isn't preserved
    protected var _hunting :String;

    // Bye bye type checking
    protected const _svc :Object = {
        getState: function () :String {
            return (_quest.getHealth() == 0) ? QuestConstants.STATE_DEAD : _ctrl.getState();
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

        awardRandomItem: function (level :int) :void {
        },

        awardXP: function (amount :int) :void {
            // Sure, monsters can level up
            _ctrl.setMemory("xp", int(_ctrl.getMemory("xp")) + amount);
        },

        revive: function () :void {
            _ctrl.setMemory("health", _quest.getMaxHealth());
        },

        damage: function (source :Object, amount :int, cause :Object = null) :void {
            _quest.damage(source, amount, cause);
        }
    };
}
}
