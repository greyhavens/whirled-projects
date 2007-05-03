//
// $Id$

package com.threerings.betthefarm {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.text.TextField;

public class Plaque extends Sprite {
    public static const STATE_NORMAL :uint = 1;
    public static const STATE_TYPING :uint = 2;
    public static const STATE_CORRECT :uint = 3;
    public static const STATE_INCORRECT :uint = 4;

    public function Plaque (state :uint = STATE_NORMAL)
    {
        super();

        _textField = new TextField();
        addChild(_textField);
        setText("PLAQUE");

        setState(state);
    }

    public function setText (text :String) :void
    {
        _textField.text = text;
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
    protected var _textField :TextField;
    protected var _background :DisplayObject;
}
}
