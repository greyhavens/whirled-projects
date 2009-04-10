package vampire.quest.client {

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.objects.DraggableObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.quest.PlayerQuestStats;

public class StatDebugPanel extends DraggableObject
{
    public function StatDebugPanel (stats :PlayerQuestStats) :void
    {
        _stats = stats;

        _sprite = new Sprite();

        var g :Graphics = _sprite.graphics;
        g.lineStyle(1, 0);
        g.beginFill(0xffffff);
        g.drawRect(0, 0, WIDTH, HEIGHT);
        g.endFill();

        _layoutSprite = new Sprite();
        _layoutSprite.x = MARGIN;
        _layoutSprite.y = MARGIN;
        _sprite.addChild(_layoutSprite);

        createButton("Set Stat", function (...ignored) :void {
            _stats.setStat(getEnteredName(), getEnteredVal());
        });

        createButton("Get Stat", function (...ignored) :void {
            var name :String = getEnteredName();
            setStatusText("Stat", "name", name, "val", _stats.getStat(name).toString());
        });
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function createButton (buttonText :String, callback :Function) :SimpleButton
    {
        var btn :SimpleTextButton = new SimpleTextButton(buttonText);
        layoutElement(btn);
        btn.addEventListener(MouseEvent.CLICK,
            function () :void {
                try {
                    callback();
                } catch (e :Error) {
                    setStatusText("Error!", e);
                }
            });
        return btn;
    }

    protected function layoutElement (disp :DisplayObject, indent :Number = 0) :void
    {
        if (_layoutX + disp.width + indent > WIDTH + (MARGIN * 2)) {
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

    protected function getEnteredName () :String
    {
        return _nameField.text;
    }

    protected function getEnteredVal () :Object
    {
        var text :String = _valueField.text;
        return (text == null || text.length == 0 || text == "null" ? null : text);
    }

    protected function setStatusText (...args) :void
    {
        TextBits.initTextField(_status, formatStatus(args), 1.5, 0, 0, "left");
        DisplayUtil.positionBounds(_status, 10, HEIGHT - _status.height - MARGIN);
    }

    protected static function formatStatus (args :Array) :String
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

    protected var _stats :PlayerQuestStats;

    protected var _sprite :Sprite;
    protected var _status :TextField;

    protected var _nameField :TextField;
    protected var _valueField :TextField;

    protected var _layoutSprite :Sprite;
    protected var _layoutX :Number = 0;
    protected var _layoutY :Number = 0;

    protected static const WIDTH :Number = 300;
    protected static const HEIGHT :Number = 200;
    protected static const MARGIN :Number = 10;
    protected static const ELEMENT_OFFSET_X :Number = 5;
    protected static const ELEMENT_OFFSET_Y :Number = 5;
}

}
