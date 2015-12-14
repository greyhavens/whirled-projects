//
// $Id$

package dictattack {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.util.Log;

/**
 * Used to display a popup dialog.
 */
public class Dialog extends Sprite
{
    public static const LEFT :int = 0;
    public static const RIGHT :int = 1;
    public static const CENTER :int = 2;

    public function Dialog (ctx :Context, content :DisplayObject = null)
    {
        _ctx = ctx;
        if (content != null) {
            setContent(content);
        }
    }

    public function setContent (content :DisplayObject) :void
    {
        content.x = BORDER;
        content.y = BORDER;
        addChild(_content = content);
    }

    public function addButton (button :SimpleButton, position :int) :void
    {
        switch (position) {
        case LEFT:
            button.x = BORDER;
            break;
        case RIGHT:
            button.x = BORDER + _content.width - button.width;
            break;
        case CENTER:
            button.x = BORDER + (_content.width - button.width)/2;
            break;
        }
        button.y = BORDER + _content.height + BORDER;
        addChild(button);
    }

    public function show (fromTop :Boolean = true) :void
    {
        // draw a background and border around our bits
        graphics.beginFill(uint(0x222222));
        graphics.lineStyle(2, 0xCCCCCC);
        graphics.drawRect(0, 0, width + 2*BORDER, height + 2*BORDER);
        graphics.endFill();

        var dx :int, dy :int;
        var board :Board = _ctx.view.getBoard();
        if (board == null) {
            dx = (_ctx.control.local.getSize().x - width)/2;
            dy = (_ctx.control.local.getSize().y - height)/2;
        } else {
            dx = Content.BOARD_BORDER + (board.getPixelSize() - width)/2;
            dx = Math.max(5, dx);
            dy = Content.BOARD_BORDER + (board.getPixelSize() - height)/2;
        }

        _ctx.top.addChild(this);
        if (fromTop) {
            LinePath.move(this, dx, -height, dx, dy, 500).start();
        } else {
            LinePath.move(this, dx, _ctx.control.local.getSize().y + height, dx, dy, 500).start();
        }
    }

    public function clear () :void
    {
        // if we've already been asked to clear, ignore subsequent reqeusts
        if (_content == null) {
            return;
        }
        _content = null;

        var meMyselfAndI :Sprite = this;
        LinePath.moveTo(this, x, -height, 500).start(function (path :Path) :void {
            _ctx.top.removeChild(meMyselfAndI);
            if (_ctx.view != null) {
                _ctx.view.focusInput(true);
            }
        });
    }

    protected static function setText (view :MovieClip, name :String, text :String,
                                       autoSize :Boolean = false) :TextField
    {
        var tfield :TextField = (view.getChildByName(name) as TextField);
        if (tfield == null) {
            Log.getLog(Dialog).warning("Missing text field for set [name=" + name + "].");
        } else {
            if (autoSize) {
                tfield.autoSize = TextFieldAutoSize.LEFT;
            }
            tfield.text = text;
        }
        return tfield;
    }

    protected static function removeViewChild (view :MovieClip, name :String) :void
    {
        var child :DisplayObject = view.getChildByName(name);
        if (child == null) {
            Log.getLog(Dialog).warning("Missing child for remove [name=" + name + "].");
        } else {
            view.removeChild(child);
        }
    }

    protected var _ctx :Context;
    protected var _content :DisplayObject;

    protected static const BORDER :int = 15;
}
}
