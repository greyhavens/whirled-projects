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
        _doll.layer([52, 123, 245, 463, 349]);
        _doll.scaleX = 2;
        _doll.scaleY = 2;
        _doll.smoothing = true;

        _quest = new QuestSprite(_ctrl, _doll);
        _quest.bounciness = 20;
        _quest.bounceFreq = 200;
        addChild(_quest);

        _ctrl.registerPropertyProvider(propertyProvider);

        _ctrl.registerStates(QuestConstants.STATE_ATTACK, QuestConstants.STATE_COUNTER, QuestConstants.STATE_HEAL);
        _ctrl.registerActions("Inventory");

        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, function (..._) {
            _ctrl.setMemory("health", Math.random());
        });
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

    // Bye bye type checking
    protected const _svc :Object = {
        getState: function () :String {
            return _ctrl.getState();
        },

        getType: function () :String {
            return QuestConstants.TYPE_PLAYER;
        },

        damage: function (amount :Number, cause :String = null) :void {
            _quest.damage(amount, cause);
        }
    };
}
}
