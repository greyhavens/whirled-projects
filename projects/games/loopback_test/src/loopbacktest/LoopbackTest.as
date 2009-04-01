package loopbacktest {

import com.threerings.flash.SimpleTextButton;
import com.whirled.game.GameControl;
import com.whirled.game.loopback.LoopbackGameControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

[SWF(width="700", height="500", frameRate="30")]
public class LoopbackTest extends Sprite
{
    public function LoopbackTest ()
    {
        _gameCtrl = new LoopbackGameControl(this);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);

        // background
        var g :Graphics = this.graphics;
        g.lineStyle(2, 0);
        g.beginFill(0xffffff);
        g.drawRect(0, 0, 700, 500);
        g.endFill();

        // status text
        _status = new TextField();
        setStatusText("LoopbackTest");
        addChild(_status);

        // buttons
        _buttonSprite = new Sprite();
        _buttonSprite.x = 10;
        _buttonSprite.y = 10;
        addChild(_buttonSprite);

        var sendMsgBtn :SimpleTextButton = new SimpleTextButton("Send message");
        layoutButton(sendMsgBtn);
        sendMsgBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.sendMessage("Hello!", null);
            });

        var propVal :int;
        var setPropBtn :SimpleTextButton = new SimpleTextButton("Set Prop");
        layoutButton(setPropBtn);
        setPropBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.set("MyProp", propVal++, false);
            });

        var immediatePropVal :int;
        var setPropImmediateBtn :SimpleTextButton = new SimpleTextButton("Set Prop Immediate");
        layoutButton(setPropImmediateBtn);
        setPropImmediateBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.set("MyImmediateProp", immediatePropVal--, true);
            });

        var elemVal :int;
        var setElemBtn :SimpleTextButton = new SimpleTextButton("Set Element");
        layoutButton(setElemBtn);
        setElemBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.setIn("Dictionary", 666, elemVal++);
            });
    }

    protected function layoutButton (button :SimpleTextButton) :void
    {
        if (_buttonX + button.width > BUTTON_SPRITE_WIDTH) {
            _buttonX = 0;
            _buttonY = _buttonSprite.height + BUTTON_OFFSET_Y;
        }

        button.x = _buttonX;
        button.y = _buttonY;
        _buttonSprite.addChild(button);

        _buttonX += button.width + BUTTON_OFFSET_X;
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        setStatusText(formatStatus("MsgReceived", "name", e.name));
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        setStatusText(formatStatus("PropChanged", "name", e.name, "newVal", e.newValue,
            "oldVal", e.oldValue));
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        setStatusText(formatStatus("ElemChanged", "name", e.name, "key", e.key,
            "newVal", e.newValue, "oldVal", e.oldValue));
    }

    protected function setStatusText (text :String) :void
    {
        TextBits.initTextField(_status, text, 1.5, 0, 0, "left");
        _status.x = 10;
        _status.y = this.height - 40;
    }

    protected static function formatStatus (...args) :String
    {
        var msg :String = "";
        if (args.length > 0) {
            msg += " " + String(args[0]); // the primary log message
            var err :Error = null;
            if (args.length % 2 == 0) { // there's one extra arg
                var lastArg :Object = args.pop();
                if (lastArg is Error) {
                    err = lastArg as Error; // ok, it's an error, we like those
                } else {
                    args.push(lastArg, ""); // what? Well, cope by pushing it back with a ""
                }
            }
            if (args.length > 1) {
                for (var ii :int = 1; ii < args.length; ii += 2) {
                    msg += (ii == 1) ? " [" : ", ";
                    msg += String(args[ii]) + "=" + String(args[ii + 1]);
                }
                msg += "]";
            }
            if (err != null) {
                msg += "\n" + err.getStackTrace();
            }
        }
        return msg;
    }

    protected var _gameCtrl :GameControl;
    protected var _status :TextField;

    protected var _buttonSprite :Sprite;
    protected var _buttonX :Number = 0;
    protected var _buttonY :Number = 0;

    protected static const BUTTON_SPRITE_WIDTH :Number = 680;
    protected static const BUTTON_SPRITE_HEIGHT :Number = 480;
    protected static const BUTTON_OFFSET_X :Number = 5;
    protected static const BUTTON_OFFSET_Y :Number = 5;
}

}
