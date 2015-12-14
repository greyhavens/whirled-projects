// $Id$

package com.threerings.graffiti.tools {

import flash.display.DisplayObject;
import flash.display.SimpleButton;

public class ToggleButton
{
    public function ToggleButton (button :SimpleButton, value :*)
    {
        _button = button;
        _overState = _button.overState;
        _upState = _button.upState;
        _value = value;
    }

    public function get button () :SimpleButton
    {
        return _button;
    }

    public function get value () :*
    {
        return _value;
    }

    public function set selected (value :Boolean) :void
    {
        if (value) {
            _button.overState = _button.downState;
            _button.upState = _button.downState;
        } else {
            _button.overState = _overState;
            _button.upState = _upState;
        }
    }

    public function get selected () :Boolean
    {
        return _button.overState == _button.downState;
    }

    protected var _button :SimpleButton;
    protected var _upState :DisplayObject;
    protected var _overState :DisplayObject;
    protected var _value :*;
}
}
