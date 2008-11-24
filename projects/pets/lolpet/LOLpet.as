//
// $Id$
//
// LOLpet - a pet for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import com.threerings.flash.TextFieldUtil;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;
import com.whirled.PetControl;

/**
 * LOLpet is the coolest Pet ever.
 */
[SWF(width="300", height="300")]
public class LOLpet extends Sprite
{
    public static const WIDTH :int = 300;
    public static const HEIGHT :int = 300;

    public function LOLpet ()
    {
        // instantiate and wire up our control
        _ctrl = new PetControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.addEventListener(ControlEvent.CHAT_RECEIVED, handleChatReceived);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);

        _lolField = TextFieldUtil.createField("", 
            {
                autoSize: TextFieldAutoSize.CENTER,
                width: WIDTH,
                y: HEIGHT/2
            },
            {
                color: 0x000000,
                font: "sans",
                size: 11
            });
        addChild(_lolField);
        _levelField = TextFieldUtil.createField("",
            {
                autoSize: TextFieldAutoSize.CENTER,
                outlineColor: 0xFFFFFF,
                width: WIDTH
            },
            {
                bold: true,
                color: 0xFF0000,
                font: "sans",
                size: 18
            });
        addChild(_levelField);

         // do 
        _ctrl.doBatch(init);
    }

    protected function init () :void
    {
        _myId = _ctrl.getMyEntityId();

        // read any unchanging memories
        var c :Object = _ctrl.getMemory("c", null);
        if (c != null) {
            _color = uint(c);

        } else {
            _color = (Math.random() < .503) ? 0xFFDDD : 0XDDDDFF;
            _ctrl.setMemory("c", _color);
        }

        // now check these boys
        updateLOLS(Number(_ctrl.getMemory("lol", 0)));
        updateLevel(int(_ctrl.getMemory("lvl", 0)));

        _ctrl.sendChat("I am lolpet. I am here now. I didn't say anything funny.");
    }

    protected function handleMemoryChanged (event :ControlEvent = null) :void
    {
        updateLOLS(Number(_ctrl.getMemory("lol", 0)));
        updateLevel(int(_ctrl.getMemory("lvl", 0)));
    }

    protected function handleChatReceived (event :ControlEvent) :void
    {
        var id :String = event.name;
        var chat :String = String(event.value);
        if (_myId == id) {
            return; // never trigger off ourselves
        }

        var result :Object = LOL.exec(chat);
        var hasLOL :Boolean = (result != null);
        var isLOL :Boolean = hasLOL && (result[0] == chat);
        var isPet :Boolean =
            (EntityControl.TYPE_PET == _ctrl.getEntityProperty(EntityControl.PROP_TYPE, id));

        if ((isPet || !hasLOL) && (Math.random() > (_level / 100))) {
            return; // don't react
        }

        var lolchat :String = "lol";
        if (isLOL) {
            lolchat += "!";
        } else if (!hasLOL) {
            lolchat += "@" + _ctrl.getEntityProperty(EntityControl.PROP_NAME, id);
        }
        _ctrl.doBatch(sendLOL, lolchat);
    }

    protected function sendLOL (lolchat :String) :void
    {
        _ctrl.sendChat(lolchat);
        var lol :Number = _lols + 1;
        _ctrl.setMemory("lol", lol);
        if (lol > (5 * Math.pow(2, _level))) {
            _ctrl.setMemory("lvl", int(_level + 1));
        }
    }
            
    protected function updateLOLS (lols :Number) :void
    {
        _lols = lols;
        TextFieldUtil.updateText(_lolField, String(lols));
    }

    protected function updateLevel (level :int) :void
    {
        if (level == _level) {
            return;
        }
        // TODO animate: if (!isNaN(_level)) {
        TextFieldUtil.updateFormat(_levelField, { size: 12 + level });
        TextFieldUtil.updateText(_levelField, "Level " + String(level));
        _levelField.y = HEIGHT/2 - _levelField.height;
        _level = level;

        const hExtent :Number = 80 + ((WIDTH/2 - 80) * (level / 32));
        const vExtent :Number = .75 * hExtent;
        graphics.clear();
        graphics.beginFill(_color);
        graphics.drawEllipse((WIDTH - hExtent)/2, (HEIGHT - vExtent)/2, hExtent, vExtent);
        graphics.endFill();
        graphics.lineStyle(0x000000);
        graphics.drawEllipse((WIDTH - hExtent)/2, (HEIGHT - vExtent)/2, hExtent, vExtent);
    }

    /**
     * This is called when your pet is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
    }

    protected static const LOL :RegExp = /\blol\b/i;

    protected var _lols :Number;

    protected var _level :Number = NaN;

    protected var _color :uint;

    protected var _levelField :TextField;
    protected var _lolField :TextField;

    protected var _ctrl :PetControl;
    protected var _myId :String;
}
}
