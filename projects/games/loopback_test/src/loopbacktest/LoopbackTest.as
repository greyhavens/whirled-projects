package loopbacktest {

import com.threerings.flash.SimpleTextButton;
import com.whirled.game.GameControl;
import com.whirled.game.loopback.LoopbackGameControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
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

        _layoutSprite = new Sprite();
        _layoutSprite.x = 10;
        _layoutSprite.y = 10;
        addChild(_layoutSprite);

        // status text
        _status = new TextField();
        setStatusText("LoopbackTest");
        addChild(_status);

        // text entry
        layoutElement(TextBits.createText("Name:", 1.2));
        _nameField = TextBits.createInputText(100, 18, 1.2, 0, "MyProp");
        layoutElement(_nameField);
        layoutElement(TextBits.createText("Val:", 1.2), 10);
        _valueField = TextBits.createInputText(100, 18, 1.2, 0, "MyVal");
        layoutElement(_valueField);
        layoutElement(TextBits.createText("Key:", 1.2), 10);
        _keyField = TextBits.createInputText(100, 18, 1.2, 0, "666");
        layoutElement(_keyField);
        layoutElement(TextBits.createText("Test Val:", 1.2), 10);
        _testField = TextBits.createInputText(100, 18, 1.2, 0, "MyVal");
        layoutElement(_testField);
        createNewLayoutRow(10);

        // Send Message
        var sendMsgBtn :SimpleTextButton = new SimpleTextButton("Send message");
        layoutElement(sendMsgBtn);
        sendMsgBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.sendMessage(getEnteredName(), getEnteredVal());
            });

        // Set Prop
        var setPropBtn :SimpleTextButton = new SimpleTextButton("Set Prop");
        layoutElement(setPropBtn);
        setPropBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.set(getEnteredName(), getEnteredVal(), false);
            });

        // Delete Prop
        var deletePropBtn :SimpleTextButton = new SimpleTextButton("Delete Prop");
        layoutElement(deletePropBtn);
        deletePropBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.set(getEnteredName(), null, false);
            });

        // Set Prop Immediate
        var setPropImmediateBtn :SimpleTextButton = new SimpleTextButton("Set Prop Immediate");
        layoutElement(setPropImmediateBtn);
        setPropImmediateBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.set(getEnteredName(), getEnteredVal(), true);
            });

        // Test and Set
        var testAndSetBtn :SimpleTextButton = new SimpleTextButton("Test and Set");
        layoutElement(testAndSetBtn);
        testAndSetBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.testAndSet(getEnteredName(), getEnteredVal(), getTestVal());
            });

        // Set Element
        var setElemBtn :SimpleTextButton = new SimpleTextButton("Set Element");
        layoutElement(setElemBtn);
        setElemBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.setIn(getEnteredName(), getEnteredKey(), getEnteredVal());
            });

        // Delete Element
        var delElemBtn :SimpleTextButton = new SimpleTextButton("Delete Element");
        layoutElement(delElemBtn);
        delElemBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.setIn(getEnteredName(), getEnteredKey(), null);
            });

        // Batch Transaction
        var batchVal :int;
        var batchBtn :SimpleTextButton = new SimpleTextButton("Batch Transaction");
        layoutElement(batchBtn);
        batchBtn.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.doBatch(function () :void {
                    for (var ii :int = 0; ii < 3; ++ii){
                        _gameCtrl.net.set("BatchProp", batchVal++, false);
                    }
                })
            });
    }

    protected function layoutElement (disp :DisplayObject, indent :Number = 0) :void
    {
        if (_layoutX + disp.width + indent > LAYOUT_SPRITE_WIDTH) {
            createNewLayoutRow();
        }

        disp.x = _layoutX + indent;
        disp.y = _layoutY;
        _layoutSprite.addChild(disp);

        _layoutX += disp.width + indent + ELEMENT_OFFSET_X;
    }

    protected function createNewLayoutRow (yOffset :Number = 0) :void
    {
        _layoutX = 0;
        _layoutY = _layoutSprite.height + ELEMENT_OFFSET_Y + yOffset;
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        setStatusText(formatStatus("MsgReceived", "name", e.name, "val", e.value));
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

    protected function getEnteredName () :String
    {
        return _nameField.text;
    }

    protected function getEnteredVal () :Object
    {
        var text :String = _valueField.text;
        return (text == null || text.length == 0 || text == "null" ? null : text);
    }

    protected function getTestVal () :Object
    {
        var text :String = _testField.text;
        return (text == null || text.length == 0 || text == "null" ? null : text);
    }

    protected function getEnteredKey () :int
    {
        return int(_keyField.text);
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

    protected var _nameField :TextField;
    protected var _valueField :TextField;
    protected var _keyField :TextField;
    protected var _testField :TextField;

    protected var _layoutSprite :Sprite;
    protected var _layoutX :Number = 0;
    protected var _layoutY :Number = 0;

    protected static const LAYOUT_SPRITE_WIDTH :Number = 680;
    protected static const LAYOUT_SPRITE_HEIGHT :Number = 480;
    protected static const ELEMENT_OFFSET_X :Number = 5;
    protected static const ELEMENT_OFFSET_Y :Number = 5;
}

}
