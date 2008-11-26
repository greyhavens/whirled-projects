//
// $Id$

package {

import flash.events.Event;
import flash.events.TimerEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import flash.media.Sound;

import com.whirled.EntityControl;
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

    protected function tick (event :TimerEvent) :void
    {
        if (_quest.getHealth()/_quest.getMaxHealth() < 0.25) {
            _hunting = null;
            _ctrl.setState(QuestConstants.STATE_HEAL);
            var bounds :Array = _ctrl.getRoomBounds();
            walkTo([ bounds[0]*Math.random(), 0, bounds[2]*Math.random() ]); // Flee!
        } else {
            switchTarget();
            _ctrl.setState([QuestConstants.STATE_ATTACK, QuestConstants.STATE_COUNTER]
                    [int(Math.random()*2)]);
        }
    }

    // Pick a victim and charge at it
    protected function switchTarget () :void
    {
        var targets :Array = QuestUtil.query(_ctrl, function (svc :Object, id :String) :Boolean {
            return svc.getType() == QuestConstants.TYPE_PLAYER &&
                QuestUtil.squareDistanceTo(_ctrl, id) < 1000*1000;
        });

        _hunting = targets[int(Math.random()*targets.length)].getIdent();

        stalkTo(_ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL, _hunting) as Array);
    }


    // Move to some target, but keep a certain distance away
    protected function stalkTo (pixel :Array, distance :Number = NaN) :void
    {
        if (isNaN(distance)) {
            distance = _svc.getRange();
        }

        var here :Array = _ctrl.getPixelLocation() as Array;

        var v :Array = [ pixel[0]-here[0], 0, pixel[2]-here[2] ]; // Vector from here->pixel
        var d :Number = Math.sqrt(v[0]*v[0] + v[2]*v[2]); // Magnitude
        var u :Array = [ v[0]/d, 0, v[2]/d ]; // Unit vector

        var to :Array = [ here[0] + v[0]-distance*u[0], 0, here[2] + v[2]-distance*u[2] ];

        // Prevent myself from walking of screen
        var bounds :Array = _ctrl.getRoomBounds();
        to[0] = Math.max(0, Math.min(to[0], bounds[0]));
        to[2] = Math.max(0, Math.min(to[2], bounds[2]));

        walkTo(to, pixel); // Walk there, facing the player
    }

    protected function handleMovement (event :ControlEvent) :void
    {
        if (event.name == _hunting && event.value != null) {
            var bounds :Array = _ctrl.getRoomBounds();
            stalkTo([ event.value[0]*bounds[0], 0, event.value[2]*bounds[2] ]); // Convert to pixel
        }
    }

    protected function walkTo (pixel :Array, facing :Array = null) :void
    {
        if (facing == null) {
            facing = _ctrl.getPixelLocation() as Array;
            facing[0] = 2*pixel[0] - facing[0];
            facing[2] = 2*pixel[2] - facing[2];
        }
        var angle :Number = Math.atan2(facing[2]-pixel[2], facing[0]-pixel[0]); // Radians
        angle = (360 + 90 + Math.round(180/Math.PI * angle)) % 360; // Convert to our degree system

        _ctrl.setPixelLocation(pixel[0], pixel[1], pixel[2], angle);
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
                        _hunting = null;
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
            return 100;
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

        hasTrait: function () :Boolean {
            return false; // TODO?
        },

        damage: function (
            source :Object, amount :int, cause :Object = null, ignoreArmor :Boolean = false) :void {
            _quest.damage(source, amount, cause, ignoreArmor);
        }
    };
}
}
