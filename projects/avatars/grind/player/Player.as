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
        _doll.scaleX = 2;
        _doll.scaleY = 2;

        _quest = new QuestSprite(_ctrl, _doll);
        _quest.bounciness = 20;
        _quest.bounceFreq = 200;
        addChild(_quest);

        _ctrl.registerPropertyProvider(propertyProvider);

        _ctrl.registerStates(QuestConstants.STATE_ATTACK, QuestConstants.STATE_COUNTER, QuestConstants.STATE_HEAL);
        _ctrl.registerActions("Inventory", "Cheat");

        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);

        _inventory = new Inventory(_ctrl, _doll);
    }

    public function handleAction (event :ControlEvent) :void
    {
        switch (event.name) {
            case "Inventory":
                _ctrl.showPopup("Inventory", _inventory, _inventory.width, _inventory.height, 0, 0.8);
                break;
            case "Cheat":
                _ctrl.setMemory("xp", Number(_ctrl.getMemory("xp")) + 100);
                _inventory.deposit(int(Math.random()*Items.TABLE.length), 0);
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

    protected var _inventory :Inventory;

    // Bye bye type checking
    protected const _svc :Object = {
        getState: function () :String {
            return _ctrl.getState();
        },

        getType: function () :String {
            return QuestConstants.TYPE_PLAYER;
        },

        getPower: function () :Number {
            return 0.2;
        },

        getDefence: function () :Number {
            return 0;
        },

        damage: function (amount :Number, cause :String = null) :void {
            _quest.damage(amount, cause);
        }
    };
}
}
