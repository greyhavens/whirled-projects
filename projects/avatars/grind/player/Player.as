//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="64", height="250")]
public class Player extends Sprite
{
    public function Player ()
    {
        _ctrl = new AvatarControl(this);

        _doll = new Doll();
        _doll.layer([200]);

        _quest = new QuestSprite(_ctrl, _doll);
        addChild(_quest);

        _ctrl.registerPropertyProvider(propertyProvider);

        _ctrl.registerStates(QuestConstants.STATE_ATTACK, QuestConstants.STATE_COUNTER, QuestConstants.STATE_HEAL);
        _ctrl.registerActions("Inventory", "Cheat");

        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemory);

        _inventory = new Inventory(_ctrl, _doll);
        _ghost = Bitmap(new GHOST());
        _ghost.smoothing = true;

        handleMemory();
    }

    public function handleMemory (... _) :void
    {
        if (_quest.getHealth() == 0) {
            _quest.bounciness = 10;
            _quest.bounceFreq = 1000;
            _quest.setActor(_ghost);
        } else {
            _quest.bounciness = 20;
            _quest.bounceFreq = 200;
            _quest.setActor(_doll);
        }
    }

    public function handleAction (event :ControlEvent) :void
    {
        switch (event.name) {
            case "Inventory":
                _ctrl.showPopup("Inventory", _inventory, _inventory.width, _inventory.height, 0, 0.8);
                break;
            case "Cheat":
                _svc.awardXP(110);
                for (var i:int = 0;i<5;++i) {
                    _inventory.deposit(int(Math.random()*Items.TABLE.length), 0);
                }
                if (_svc.getState() == QuestConstants.STATE_DEAD) {
                    _svc.revive();
                }
                break;
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

    protected var _ctrl :AvatarControl;

    protected var _quest :QuestSprite;

    protected var _doll :Doll;

    [Embed(source="ghost.png")]
    protected static const GHOST :Class;
    protected var _ghost :Bitmap;

    protected var _inventory :Inventory;

    // Bye bye type checking
    protected const _svc :Object = {
        getState: function () :String {
            return (_quest.getHealth() == 0) ? QuestConstants.STATE_DEAD : _ctrl.getState();
        },

        getType: function () :String {
            return QuestConstants.TYPE_PLAYER;
        },

        getPower: function () :Number {
            return _inventory.getPower();
        },

        getDefence: function () :Number {
            return 0; // TODO
        },

        getRange: function () :Number {
            return _inventory.getRange(); // Use the range of the equipped weapon
        },

        awardRandomItem: function (level :int) :void {
        },

        awardXP: function (amount :int) :void {
            _ctrl.setMemory("xp", int(_ctrl.getMemory("xp")) + amount);
        },

        revive: function () :void {
            _quest.echo("Revived!");
            _ctrl.setMemory("health", int(_quest.getMaxHealth()/2));
        },

        damage: function (source :Object, amount :int, cause :String = null) :void {
            _quest.damage(source, amount, cause);
        }
    };
}
}
