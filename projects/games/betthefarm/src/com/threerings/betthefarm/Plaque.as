//
// $Id$

package com.threerings.betthefarm {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class Plaque extends Sprite {
    public static const STATE_NORMAL :uint = 1;
    public static const STATE_TYPING :uint = 2;
    public static const STATE_CORRECT :uint = 3;
    public static const STATE_INCORRECT :uint = 4;

    public function Plaque (name :String, state :uint = STATE_NORMAL)
    {
        super();

        setState(state);

        _textField = new TextField();
        _textField.autoSize = TextFieldAutoSize.NONE;
        _textField.width = _background.width;
        _textField.height = _background.height;

        var format :TextFormat = new TextFormat();
        format.size = 12;
        format.font = Content.FONT_NAME;
        format.color = Content.FONT_COLOR;
        format.align = TextFormatAlign.CENTER;
        _textField.defaultTextFormat = format;
        addChild(_textField);

        _name = name;
        _textField.text = _name;
    }

    public function setFlow (flow :int) :void
    {
        _textField.text = _name + "\n" + flow;
    }

    public function setState (state :uint) :void
    {
        if (state == _state) {
            return;
        }
        _state = state;
        if (_background) {
            removeChild(_background);
        }
        switch(state) {
        case STATE_NORMAL:
        default:
            _background = new Content.PLAQUE_NORMAL();
            break;
        case STATE_TYPING:
            _background = new Content.PLAQUE_TYPING();
            break;
        case STATE_CORRECT:
            _background = new Content.PLAQUE_CORRECT();
            break;
        case STATE_INCORRECT:
            _background = new Content.PLAQUE_INCORRECT();
            break;
        }
        addChildAt(_background, 0);
    }

    protected var _state :uint;
    protected var _name :String;
    protected var _textField :TextField;
    protected var _background :DisplayObject;
}
}
