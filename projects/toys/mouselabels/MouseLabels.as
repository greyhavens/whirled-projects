//
// $Id$
//
// MouseLabels - a piece of furni for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.geom.Matrix;

import flash.utils.Dictionary;
import flash.utils.getTimer; // function import

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

/**
 * Creates a labelled mouse pointer for every user in the room.
 */
[SWF(width="500", height="500")]
// TODO:
// - mouse pointer graphic
// - something's a little off with the scale correction... hmm
// - clear out players who have left
public class MouseLabels extends Sprite
{
    public static const SEND_INTERVAL :int = 400;

    public function MouseLabels ()
    {
        // listen for an unload event
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // instantiate and wire up our control
        _ctrl = new FurniControl(this);
        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);
        _myId = String(_ctrl.getInstanceId());
        _myMouse = new Mousey(_ctrl.getViewerName() || "me");
        addChild(_myMouse);

        addEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleFrame (event :Event) :void
    {
        var now :int = getTimer();
        var mouse :Mousey;

        var matrix :Matrix = this.transform.concatenatedMatrix;
        if (matrix.a != _lastScale) {
            _lastScale = matrix.a;
            var mouseScale :Number = 1 / _lastScale;
            _myMouse.scaleX = mouseScale;
            _myMouse.scaleY = mouseScale;
            for each (mouse in _mice) {
                mouse.scaleX = mouseScale;
                mouse.scaleY = mouseScale;
            }
        }

        var mx :int = mouseX;
        var my :int = mouseY;
        if (mx != _lastX || my != _lastY) {
            _lastX = mx;
            _lastY = my;
            _myMouse.x = mx;
            _myMouse.y = my;
            _sendingData.push(now, mx, my);
        }
        if (now >= _nextSend && _sendingData.length > 0) {
            _ctrl.sendMessage(_myId, _sendingData);
            _sendingData = [];
            _nextSend = now + SEND_INTERVAL;
        }

        for each (mouse in _mice) {
            mouse.update(now);
        }
    }

    protected function handleMessage (event :ControlEvent) :void
    {
        var id :String = event.name;
        // ignore our own
        if (id == _myId) {
            return;
        }

        var data :Array = event.value as Array;
        var mouse :Mousey = _mice[id] as Mousey;
        if (mouse == null) {
            mouse = new Mousey(_ctrl.getViewerName(int(id)),
                int(data[0]) - getTimer() - SEND_INTERVAL);
            _mice[id] = mouse;
            addChild(mouse);
        }
        mouse.addData(data);
    }

    /**
     * This is called when your furni is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected var _ctrl :FurniControl;

    protected var _myId :String;
    protected var _myMouse :Mousey;

    protected var _lastX :int;
    protected var _lastY :int;
    protected var _lastScale :Number;

    protected var _nextSend :int = 0;

    protected var _sendingData :Array = [];

    protected var _mice :Object = {}
}
}

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.flash.TextFieldUtil;

class Mousey extends Sprite
{
    public function Mousey (name :String, offset :Number = NaN)
    {
        var tf :TextField = TextFieldUtil.createField(name,
            { textColor: 0x99BFFF, selectable: false, autoSize: TextFieldAutoSize.CENTER,
              outlineColor: 0x00000},
            { font: "_sans", size: 12, bold: true });
        tf.x = -tf.width / 2;
        tf.y = -tf.height - 10;
        addChild(tf);
        _offset = offset;

        if (!isNaN(offset)) {
            var pointer :DisplayObject = DisplayObject(new POINTER());
            pointer.x = -1;
            pointer.y = -2;
            addChild(pointer);
        }
    }

    public function addData (data :Array) :void
    {
        _data.push.apply(null, data);
    }

    public function update (now :Number) :void
    {
        if (_data.length == 0) {
            return;
        }
        var stamp :int = now + _offset;
        while (_data.length > 0 && int(_data[0]) <= stamp) {
            var nowData :Array = _data.splice(0, 3);
            x = Number(nowData[1]);
            y = Number(nowData[2]);
        }
    }

    protected var _offset :int;

    protected var _data :Array = [];

    [Embed(source="pointer.png")]
    protected static const POINTER :Class;
}

