package vampire.quest.client {

import com.threerings.display.DisplayUtil;
import com.threerings.flashbang.objects.DraggableObject;
import com.threerings.ui.SimpleTextButton;
import com.threerings.util.Log;
import com.threerings.util.StringUtil;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

public class GenericDraggableWindow extends DraggableObject
{
    public function GenericDraggableWindow (maxWidth :Number = 500, margin :Number = 20)
        :void
    {
        _sprite = new Sprite();

        _maxWidth = maxWidth;
        _margin = margin;

        _draggableSprite = new Sprite();
        _sprite.addChild(_draggableSprite);

        _layoutSprite = new Sprite();
        _layoutSprite.x = margin;
        _layoutSprite.y = margin;
        _sprite.addChild(_layoutSprite);

        // status text
        _status = new TextField();
        _sprite.addChild(_status);
        _status.x = _margin;
        setStatusText("");
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        updateSize();
    }

    protected function createButton (buttonText :String, callback :Function) :SimpleButton
    {
        var btn :SimpleTextButton = new SimpleTextButton(buttonText);
        layoutElement(btn);
        btn.addEventListener(MouseEvent.CLICK,
            function () :void {
                /*try {
                    callback();
                } catch (e :Error) {
                    setStatusText("Error!", e);
                }*/
                callback();
            });
        return btn;
    }

    protected function layoutElement (disp :DisplayObject, indent :Number = 0) :void
    {
        if (_layoutX + disp.width + indent > _maxWidth + (_margin * 2)) {
            createNewLayoutRow();
        }

        disp.x = _layoutX + indent;
        disp.y = _layoutY;
        _layoutSprite.addChild(disp);

        _layoutX += disp.width + indent + ELEMENT_OFFSET_X;

        _needsSizeUpdate = true;
    }

    protected function createNewLayoutRow (yOffset :Number = 0) :void
    {
        _layoutX = 0;
        _layoutY = _layoutSprite.height + ELEMENT_OFFSET_Y + yOffset;
    }

    protected function setStatusText (...args) :void
    {
        var text :String = formatStatus(args);
        TextBits.initTextField(_status, text, 1.5, 0, 0, "left");
        if (StringUtil.trim(text).length > 0) {
            log.info("New status: " + text);
        }
        _needsSizeUpdate = true;
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

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function get draggableObject () :InteractiveObject
    {
        return _draggableSprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        updateSize();
    }

    protected function updateSize () :void
    {
        if (_needsSizeUpdate) {
            var g :Graphics = _draggableSprite.graphics;
            g.clear();
            g.lineStyle(1, 0);
            g.beginFill(0xffffff);
            var width :Number = Math.max(_layoutSprite.width + (_margin * 2), MIN_WIDTH);
            var height :Number =
                Math.max(_layoutSprite.height + _status.height + (_margin * 2), MIN_HEIGHT);
            g.drawRect(0, 0, width, height);
            g.endFill();

            DisplayUtil.positionBounds(_status, 0, _sprite.height - _status.height - _margin);

            _needsSizeUpdate = false;
        }
    }

    protected var _sprite :Sprite;
    protected var _draggableSprite :Sprite;
    protected var _status :TextField;

    protected var _margin :Number;
    protected var _maxWidth :Number;

    protected var _needsSizeUpdate :Boolean;

    protected var _layoutSprite :Sprite;
    protected var _layoutX :Number = 0;
    protected var _layoutY :Number = 0;

    protected var log :Log = Log.getLog(this);

    protected static const MIN_WIDTH :Number = 50;
    protected static const MIN_HEIGHT :Number = 50;

    protected static const ELEMENT_OFFSET_X :Number = 5;
    protected static const ELEMENT_OFFSET_Y :Number = 5;
}

}
