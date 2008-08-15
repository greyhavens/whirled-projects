//
// $Id$

package {

import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;

import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.filters.GlowFilter;

import flash.utils.getTimer; // function import

import com.threerings.flash.SimpleTextButton;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

// [SWF(width="418", height="529")]
[SWF(width="512", height="226")]
public class Sign extends Sprite
{
    public static const WIDTH :int = 512;
    public static const HEIGHT :int = 226;
//     public static const WIDTH :int = 418;
//     public static const HEIGHT :int = 529;

    public function Sign ()
    {
        _ctrl = new FurniControl(this);
        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _post = new Sprite();
        _post.addChild(_image = Bitmap(new SIGN_IMAGE()));
        _image.smoothing = true;
        _post.x = (WIDTH - _post.width)/2;
        _post.y = HEIGHT - _post.height;
        addChild(_post);
        _ctrl.setHotSpot(WIDTH/2, HEIGHT);

        _post.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
        _post.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
    }

    protected function handleUnload (... ignored) :void
    {
        // in case we're currently animating...
        // removeEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        if (_sign != null) {
            _sign.removeEventListener(MouseEvent.CLICK, handleClick);
//             // rarely, we get big rather than small when going away, whee!
//             var tscale :Number = ((getTimer() % 10000) == 42) ? 10 : 0.1;
//             new Popper(_sign, 1, tscale, 100, function (sign :DisplayObject) :void {
//                 _ctrl.clearPopup();
//             });
            _ctrl.clearPopup();
            _sign = null;

        } else {
            var title: String = String(_ctrl.getMemory("title", DEF_TITLE));
            var text: String = String(_ctrl.getMemory("text", DEF_TEXT));
            _sign = createSign(title, text);
            _sign.addEventListener(MouseEvent.CLICK, handleClick);
            trace("Showing popup");
            _ctrl.showPopup(title, _sign, _sign.width, _sign.height);
//             // "pop" the sign into view
//             new Popper(_sign, 0.1, 1, 100);
        }
    }

    protected function handleMouseMove (event :MouseEvent) :void
    {
        setHovered(_image.bitmapData.hitTest(
                       new Point(0, 0), 0, new Point(event.localX, event.localY)));
    }

    protected function handleMouseOut (event :MouseEvent) :void
    {
        setHovered(false);
    }

    protected function setHovered (hovered :Boolean) :void
    {
        if (_hovered = hovered) {
            _post.addEventListener(MouseEvent.CLICK, handleClick);
            // only set up the filter if it hasn't already
            if (_post.filters == null || _post.filters.length == 0) {
                _post.filters = [ new GlowFilter(FILTER_COLOR, 1, 10, 10) ];
            }
        } else {
            _post.removeEventListener(MouseEvent.CLICK, handleClick);
            _post.filters = null;
        }
    }

    protected function handleEdit (event :MouseEvent) :void
    {
        var editor :Sprite = new Sprite();
        _editTitle = new TextField();
        _editTitle.type = TextFieldType.INPUT;
        _editTitle.text = String(_ctrl.getMemory("title", "Title"));
        _editTitle.width = EDITOR_WIDTH;
        _editTitle.height = 20;
        _editTitle.border = true;
        _editTitle.background = true;
        editor.addChild(_editTitle);

        _editText = new TextField();
        _editText.type = TextFieldType.INPUT;
        _editText.wordWrap = true;
        _editText.multiline = true;
        _editText.text = String(_ctrl.getMemory("text", "Text"));
        _editText.width = EDITOR_WIDTH;
        _editText.height = EDITOR_TEXT_HEIGHT;
        _editText.border = true;
        _editText.background = true;
        editor.addChild(_editText);

        _editText.y = _editTitle.height + 5;

        var save :SimpleTextButton = new SimpleTextButton(
            "Save", true, uint(0x000000), uint(0xFFFFFF), uint(0x000000), 0);
        editor.addChild(save);
        save.addEventListener(MouseEvent.CLICK, function (event: MouseEvent) :void {
            _ctrl.setMemory("title", _editTitle.text);
            _ctrl.setMemory("text", _editText.text);
            _editTitle = null;
            _editText = null;
            _ctrl.clearPopup();
        });
        save.y = _editTitle.height + _editText.height + 10;

        var cancel :SimpleTextButton = new SimpleTextButton(
            "Cancel", true, uint(0x000000), uint(0xFFFFFF), uint(0x000000), 0);
        editor.addChild(cancel);
        cancel.x = EDITOR_WIDTH - cancel.width;
        cancel.y = _editTitle.height + _editText.height + 10;
        cancel.addEventListener(MouseEvent.CLICK, function (event: MouseEvent) :void {
            _editTitle = null;
            _editText = null;
            _ctrl.clearPopup();
        });

        _ctrl.showPopup("Edit Sign", editor, editor.width, editor.height);
    }

    protected function createSign (titleText :String, signText :String) :Sprite
    {
        var sign :Sprite = new Sprite();

        var title :TextField = createLabel(titleText, null, TITLE_SIZE);
        sign.addChild(title);

        var text :TextField = createLabel(null, signText, TEXT_SIZE);
        sign.addChild(text);

        var width :int = Math.max(title.width, text.width);
        var height :int = title.height + text.height;

        // now lay everything out
        title.x = BORDER + (width - title.width)/2;
        title.y = BORDER;
        text.x = BORDER + (width - text.width)/2;
        text.y = BORDER + title.height;

        // if they have editing access, add an edit button at the bottom
        if (_ctrl.canEditRoom()) {
            var edit :TextField = createLabel("Edit", null, TIP_SIZE, true);
            sign.addChild(edit);
            edit.x = BORDER;
            edit.y = BORDER + height;
            edit.addEventListener(MouseEvent.CLICK, handleEdit);
        }

        var close :TextField = createLabel("Close", null, TIP_SIZE, true);
        sign.addChild(close);
        close.x = BORDER + (width - close.width);
        close.y = BORDER + height;
        height += close.height;

        // create our background and border
        var bg :Sprite = Sprite(new BACKGROUND());
//         bg.width = (width + 2*BORDER);
//         bg.height = (height + 2*BORDER);
        sign.addChildAt(bg, 0);

        // draw a background and border for the text
        var g :Graphics = sign.graphics;
        g.beginFill(BACKGROUND_COLOR);
        g.lineStyle(2, 0x333333);
        g.drawRoundRect(0, 0, width + 2*BORDER, height + 2*BORDER, BORDER, BORDER);
        g.endFill();

        return sign;
    }

    protected function createLabel (
        text :String, htmlText :String, size :int, link :Boolean = false) :TextField
    {
        var tfield :TextField = new TextField();
        tfield.autoSize = TextFieldAutoSize.LEFT;
        tfield.selectable = false;
        tfield.antiAliasType = AntiAliasType.ADVANCED;
        tfield.gridFitType = GridFitType.PIXEL;

        // these must be set before we apply the format below, yay Flash!
        if (text != null) {
            tfield.text = text;
        }
        if (htmlText != null) {
            tfield.htmlText = htmlText;
        }

        var format :TextFormat = new TextFormat();
        format.font = "Verdana";
        format.size = size;
        if (link) {
            format.underline = true;
        }
        tfield.setTextFormat(format);

        return tfield;
    }

    protected var _ctrl :FurniControl;
    protected var _image :Bitmap;
    protected var _post :Sprite;
    protected var _sign :Sprite;

    protected var _editTitle :TextField;
    protected var _editText :TextField;

    protected var _hovered :Boolean;

    protected static const BORDER :int = 15;
    protected static const TITLE_SIZE :int = 24;
    protected static const TEXT_SIZE :int = 18;
    protected static const TIP_SIZE :int = 12;

    protected static const BACKGROUND_COLOR :uint = 0xFFFFFF;
    protected static const FILTER_COLOR :uint = 0xFFFFFF;

    protected static const EDITOR_WIDTH :int = 250;
    protected static const EDITOR_TEXT_HEIGHT :int = 200;

    protected static const DEF_TITLE :String = "Your Title Here!";
    protected static const DEF_TEXT :String =
        "This is the text of your sign.\n" +
        "Wow people with a charming and witty\n" +
        "statement and your sign will be loved\n" +
        "and remembered for all time.";

//    [Embed(source="../rsrc/gallery.png")]
    [Embed(source="../rsrc/bravenewwhirled.png")]
    protected static var SIGN_IMAGE :Class;

    [Embed(source="../rsrc/background.swf")]
    protected static var BACKGROUND :Class;
}
}
