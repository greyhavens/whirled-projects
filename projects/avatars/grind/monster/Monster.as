//
// $Id$

package {

import flash.events.Event;

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

        _ghost = Bitmap(new GHOST());
        _ghost.smoothing = true;

        _image = Bitmap(new IMAGE());
        _image.smoothing = true;

        _quest = new QuestSprite(_ctrl, _image);
        addChild(_quest);

        handleMemory();
    }

    public function handleMemory (... _) :void
    {
//        if (_quest.getHealth() == 0) {
//            _quest.bounciness = 10;
//            _quest.bounceFreq = 1000;
//            _quest.setActor(_ghost);
//        } else {
//            _quest.bounciness = 20;
//            _quest.bounceFreq = 200;
//            _quest.setActor(_doll);
//        }
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

    // Bye bye type checking
    protected const _svc :Object = {
        getState: function () :String {
            return QuestConstants.STATE_ATTACK;//_ctrl.getState();
        },

        getType: function () :String {
            return QuestConstants.TYPE_MONSTER;
        },

        getPower: function () :Number {
            return 0.2;
        },

        getDefence: function () :Number {
            return 0;
        },

        awardRandomItem: function (level :int) :void {
        },

        awardXP: function (amount :int) :void {
            // Sure, monsters can level up
            _ctrl.setMemory("xp", int(_ctrl.getMemory("xp")) + amount);
        },

        damage: function (source :Object, amount :Number, cause :String = null) :void {
            _quest.damage(source, amount, cause);
        }
    };
}
}
