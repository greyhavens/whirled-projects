//
// $Id$

package ghostbusters.client {

import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.text.AntiAliasType;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import com.threerings.flash.SimpleTextButton;

public class TextBits extends Sprite
{
    public function TextBits ()
    {
        _styleSheet = new StyleSheet();
        _styleSheet.parseCSS(
            "body {" +
            "  color: #000000;" +
            "}" +
            ".title {" +
            "  font-family: SunnySide;" +
            "  font-size: 20;" +
            "  text-decoration: underline;" +
            "  text-align: left;" +
            "  margin-left: 20;" +
            "}" +
            ".shim {" +
            "  font-size: 8;" +
            "}" +
            ".summary {" +
            "  font-family: Goudy;" +
            "  font-weight: bold;" +
            "  font-size: 16;" +
            "  text-align: left;" +
            "}" +
            ".message {" +
            "  font-family: Goudy;" +
            "  font-size: 16;" +
            "  text-align: left;" +
            "}" +
            ".details {" +
            "  font-family: Goudy;" +
            "  font-size: 14;" +
            "  text-align: left;" +
            "}");

        _textField = new TextField();
        this.addChild(_textField);
        _textField.defaultTextFormat = getDefaultFormat();
        _textField.styleSheet = _styleSheet;
        _textField.selectable = false;
        _textField.wordWrap = true;
        _textField.multiline = true;
        _textField.embedFonts = true;
        _textField.antiAliasType = AntiAliasType.ADVANCED;
        _textField.autoSize = TextFieldAutoSize.CENTER;
        _textField.width = 400;

        _buttons = new Sprite();
        this.addChild(_buttons);

        _buttons.x = GAP;
        _buttons.y = GAP;

        _textField.x = GAP;
        _textField.y = GAP;

        _rightButtonEdge = _textField.width;
        _leftButtonEdge = 0;
    }

    public function set text (txt :String) :void
    {
        _textField.htmlText = em(txt);
    }

    public function addTextButton (label :String, right :Boolean, onClick :Function) :SimpleButton
    {
        var button :SimpleButton = new SimpleTextButton(
            label, true, 0x003366, 0x6699CC, 0x0066FF, 5, getDefaultFormat());
        button.addEventListener(MouseEvent.CLICK, function (evt :Event) :void {
                onClick();
            });
        _buttons.addChild(button);

        _textField.y = _buttons.y + _buttons.height + GAP;

        if (right) {
            button.x = _rightButtonEdge - button.width;
            _rightButtonEdge -= button.width + GAP;
        } else {
            button.x = _leftButtonEdge;
            _leftButtonEdge += button.width + GAP;
        }

        return button;
    }

    protected function addButton (label :String, right :Boolean, onClick :Function) :SimpleButton
    {
        var button :SimpleButton = new SimpleTextButton(
            label, true, 0x003366, 0x6699CC, 0x0066FF, 5, getDefaultFormat());
        button.addEventListener(MouseEvent.CLICK, function (evt :Event) :void {
                onClick();
            });
        _buttons.addChild(button);

        _textField.y = _buttons.y + _buttons.height + GAP;

        if (right) {
            button.x = _rightButtonEdge - button.width;
            _rightButtonEdge -= button.width + GAP;
        } else {
            button.x = _leftButtonEdge;
            _leftButtonEdge += button.width + GAP;
        }

        return button;
    }

    protected function getDefaultFormat () :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = "SunnySide";
        format.size = 14;
        format.color = 0x000000;
        format.align = TextFormatAlign.LEFT;
        return format;
    }

    protected static function em (text :String) :String
    {
        return text.replace(/\[\[/g, "<b><i>").replace(/\]\]/g, "</i></b>");
    }

    protected var _textField :TextField;

    protected var _buttons :Sprite;
    protected var _leftButtonEdge :int;
    protected var _rightButtonEdge :int;

    protected var _styleSheet :StyleSheet;

    protected static const GAP :int = 8;
}
}
