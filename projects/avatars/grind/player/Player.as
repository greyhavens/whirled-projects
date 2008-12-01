//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import flash.media.Sound;

import com.threerings.util.Command;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

import klass.Klass;
import klass.@KLASS@

[SWF(width="64", height="250")]
public class Player_@KLASS@ extends Sprite
{
    public function Player_@KLASS@ ()
    {
        _ctrl = new AvatarControl(this);

        _doll = new Doll();
        _doll.layer([200]);

        _quest = new PlayerSprite(_ctrl);
        addChild(_quest);

        _ctrl.registerPropertyProvider(propertyProvider);

        _ctrl.registerStates(QuestConstants.STATE_ATTACK, QuestConstants.STATE_COUNTER, QuestConstants.STATE_HEAL);
        _ctrl.registerActions("Special", "Inventory", "Cheat");

        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        Command.bind(_ctrl, ControlEvent.MEMORY_CHANGED, handleMemory);
        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);

        _inventory = new Inventory(_ctrl, _klass, _doll);
        _ghost = Bitmap(new GHOST());
        _ghost.smoothing = true;

        handleMemory();
    }

    public function handleMemory () :void
    {
        if (_quest.getHealth() == 0) {
            _quest.bounciness = 10;
            _quest.bounceFreq = 1000;
            _quest.setActor(_ghost);
            _ctrl.setMoveSpeed(200);
        } else {
            _quest.bounciness = 20;
            _quest.bounceFreq = 200;
            _quest.setActor(_doll);
            _ctrl.setMoveSpeed(500);
        }
    }

    public function handleMessage (event :ControlEvent) :void
    {
        if (event.name == "effect") {
            var effect :Object = event.value;

            if ("event" in effect) {
                switch (effect.event) {
                    case QuestConstants.EVENT_ATTACK:
                        _inventory.getAttackSound().play();
                        break;

                    case QuestConstants.EVENT_COUNTER:
                        _soundCounter.play();
                        break;

                    case QuestConstants.EVENT_HEAL:
                        _soundHeal.play();
                        break;

                    case QuestConstants.EVENT_DIE:
                        //_soundDeath.play();
                        break;
                }
            }
        }
    }

    public function handleAction (event :ControlEvent) :void
    {
        if (_ctrl.hasControl()) {
            switch (event.name) {
                case "Special":
                    _klass.handleSpecial(_ctrl, _quest);
                    break;

                case "Inventory":
                    _ctrl.showPopup("Inventory", _inventory, _inventory.width, _inventory.height, 0, 0.8);
                    break;

                case "Cheat":
                    _svc.awardXP(110);
                    //_inventory.deposit(int(Math.random()*Items.TABLE.length), 0);
                    //_inventory.deposit(int(Math.random()*6+16), 0);
                    _svc.awardRandomItem(1);
                    if (_svc.getState() == QuestConstants.STATE_DEAD) {
                        _svc.revive();
                    }
                    _inventory.getAttackSound().play();
                    break;
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

    protected var _ctrl :AvatarControl;

    protected var _quest :PlayerSprite;

    protected var _doll :Doll;

    [Embed(source="ghost.png")]
    protected static const GHOST :Class;
    protected var _ghost :Bitmap;

    protected var _inventory :Inventory;

    [Embed(source="rsrc/@KLASS@Counter.mp3")]
    protected static const SOUND_COUNTER :Class;
    protected var _soundCounter :Sound = new SOUND_COUNTER as Sound;

    [Embed(source="rsrc/@KLASS@Heal.mp3")]
    protected static const SOUND_HEAL :Class;
    protected var _soundHeal :Sound = new SOUND_HEAL as Sound;

    protected var _klass :Klass = new @KLASS@();

    // Bye bye type checking
    protected const _svc :Object = {
        getState: function () :String {
            return (_quest.getHealth() == 0) ? QuestConstants.STATE_DEAD : _ctrl.getState();
        },

        getIdent: function () :String {
            return _ctrl.getMyEntityId();
        },

        getType: function () :String {
            return QuestConstants.TYPE_PLAYER;
        },

        hasTrait: function (trait :int) :Boolean {
            return _klass.getTraits().indexOf(trait) != -1;
        },

        getPower: function () :Number {
            return _inventory.getPower();
        },

        getDefence: function () :Number {
            return _inventory.getDefence();
        },

        getRange: function () :Number {
            return _inventory.getRange(); // Use the range of the equipped weapon
        },

        getLevel: function () :int {
            return _quest.getLevel();
        },

        awardRandomItem: function (level :int) :void {
            var item :int = Items.randomLoot(level, 5);
            _inventory.deposit(item, Math.random()*7-3);
            _quest.effect({text: Items.TABLE[item][1], color: 0xffcc00});
        },

        awardXP: function (amount :int) :void {
            _ctrl.setMemory("xp", int(_ctrl.getMemory("xp")) + amount);
        },

        revive: function () :void {
            _quest.echo("Revived!");
            _ctrl.setMemory("health", int(_quest.getMaxHealth()/2));
        },

        damage: function (
            source :Object, amount :int, cause :Object = null, ignoreArmor :Boolean = false) :void {
            _quest.damage(source, amount, cause, ignoreArmor);
        }
    };
}
}
