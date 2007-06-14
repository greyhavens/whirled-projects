//
// $Id$

package {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;

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

[SWF(width="400", height="400")]
public class Sign extends Sprite
{
    public static const WIDTH :int = 400;
    public static const HEIGHT :int = 400;

    public function Sign ()
    {
        _ctrl = new FurniControl(this);
        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // TEMP: draw something to click on
        _post = new Sprite();
        var g :Graphics = _post.graphics;
        g.beginFill(0x33CC99);
        g.lineStyle(2, 0x333333);
        g.drawEllipse(-16, -8, 32, 16);
        g.endFill();
        _post.x = WIDTH/2;
        _post.y = HEIGHT;
        addChild(_post);
        _ctrl.setHotSpot(WIDTH/2, HEIGHT);

        _post.addEventListener(MouseEvent.CLICK, handleClick);
        _post.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
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
            // rarely, we get big rather than small when going away, whee!
            var tscale :Number = ((getTimer() % 10000) == 42) ? 10 : 0.1;
            new Popper(_sign, 1, tscale, 100, true);
            _sign = null;

        } else {
            var title: String = String(_ctrl.lookupMemory("title", "Title"));
            var text: String = String(_ctrl.lookupMemory("text", "Text"));
            _sign = createSign(title, text);
            _sign.addEventListener(MouseEvent.CLICK, handleClick);

            // undo our scaling
            _sign.scaleX = 1 / transform.concatenatedMatrix.a;
            _sign.scaleY = 1 / transform.concatenatedMatrix.d;

            addChild(_sign);
            _sign.x = (WIDTH - _sign.width)/2;
            _sign.y = HEIGHT - _sign.height - 10;

            // "pop" the sign into view
            new Popper(_sign, 0.1, 1, 100);
        }
    }

    protected function handleMouseOver (event :MouseEvent) :void
    {
        // only set up the filter if it hasn't already
        if (_post.filters == null || _post.filters.length == 0) {
            _post.filters = [ new GlowFilter(FILTER_COLOR, 1, 10, 10) ];
        }
    }

    protected function handleMouseOut (event :MouseEvent) :void
    {
        _post.filters = null;
    }

    protected function handleEdit (event :MouseEvent) :void
    {
        var editor :Sprite = new Sprite();
        _editTitle = new TextField();
        _editTitle.type = TextFieldType.INPUT;
        _editTitle.text = String(_ctrl.lookupMemory("title", "Title"));
        _editTitle.width = EDITOR_WIDTH;
        _editTitle.height = 20;
        _editTitle.border = true;
        _editTitle.background = true;
        editor.addChild(_editTitle);

        _editText = new TextField();
        _editText.type = TextFieldType.INPUT;
        _editText.wordWrap = true;
        _editText.multiline = true;
        _editText.text = String(_ctrl.lookupMemory("text", "Text"));
        _editText.width = EDITOR_WIDTH;
        _editText.height = EDITOR_TEXT_HEIGHT;
        _editText.border = true;
        _editText.background = true;
        editor.addChild(_editText);

        _editText.y = _editTitle.height + 5;

        var save :SimpleTextButton =
            new SimpleTextButton("Save", true, uint(0x000000), uint(0xFFFFFF), uint(0x000000), 0);
        editor.addChild(save);
        save.addEventListener(MouseEvent.CLICK, function (event: MouseEvent) :void {
            _ctrl.updateMemory("title", _editTitle.text);
            _ctrl.updateMemory("text", _editText.text);
            _editTitle = null;
            _editText = null;
            removeChild(editor);
        });
        save.y = _editTitle.height + _editText.height + 10;

        var cancel :SimpleTextButton =
            new SimpleTextButton("Cancel", true, uint(0x000000), uint(0xFFFFFF), uint(0x000000), 0);
        editor.addChild(cancel);
        cancel.x = EDITOR_WIDTH - cancel.width;
        cancel.y = _editTitle.height + _editText.height + 10;
        cancel.addEventListener(MouseEvent.CLICK, function (event: MouseEvent) :void {
            _editTitle = null;
            _editText = null;
            removeChild(editor);
        });

        // undo our scaling
        editor.scaleX = 1 / transform.concatenatedMatrix.a;
        editor.scaleY = 1 / transform.concatenatedMatrix.d;

        addChild(editor);

        editor.x = (WIDTH - editor.width)/2;
        editor.y = HEIGHT - editor.height - 10;
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

        // draw a background and border for the text
        var g :Graphics = sign.graphics;
        g.beginFill(BACKGROUND_COLOR);
        g.lineStyle(2, 0x333333);
        g.drawRect(0, 0, width + 2*BORDER, height + 2*BORDER);
        g.endFill();

        return sign;
    }

        protected function createLabel (
            text :String, htmlText :String, size :int, link :Boolean = false) :TextField
    {
        var tfield :TextField = new TextField();
        tfield.autoSize = TextFieldAutoSize.LEFT;
        tfield.selectable = false;
        tfield.embedFonts = true;
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
        format.font = "Sign";
        format.size = size;
        if (link) {
            format.underline = true;
        }
        tfield.setTextFormat(format);

        return tfield;
    }

    protected var _ctrl :FurniControl;
    protected var _post :Sprite;
    protected var _sign :Sprite;

    protected var _editTitle :TextField;
    protected var _editText :TextField;

    protected static const BORDER :int = 5;
    protected static const TITLE_SIZE :int = 24;
    protected static const TEXT_SIZE :int = 18;
    protected static const TIP_SIZE :int = 12;

    protected static const BACKGROUND_COLOR :uint = 0x99CCFF;
    protected static const FILTER_COLOR :uint = 0xFF00FF;

    protected static const EDITOR_WIDTH :int = 250;
    protected static const EDITOR_TEXT_HEIGHT :int = 200;

    [Embed(source="../rsrc/sign_font.ttf", fontName="Sign",
           mimeType="application/x-font-truetype")]
    protected static var SIGN_FONT :Class;
}
}
