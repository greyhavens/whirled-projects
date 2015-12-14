// $Id$

package com.threerings.graffiti.tools {

import flash.display.MovieClip;

import flash.events.MouseEvent;

import com.threerings.util.Log;

/**
 * The necessity of this class is a bit silly - SimpleButton doesn't have a "disabled" state, so
 * we're mimicking it with a MovieClip, and using the last state for "disabled"
 */
public class MovieClipButton
{
    public function MovieClipButton (mc :MovieClip) 
    {
        _mc = mc;
        setState(UP_STATE);

        _mc.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _mc.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        _mc.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        _mc.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    }

    public function get enabled () :Boolean
    {
        return _enabled;
    }

    public function set enabled (e :Boolean) :void
    {
        if (_enabled == e) {
            return;
        }

        _enabled = e;
        if (_enabled) {
            setState(_mouseOver ? OVER_STATE : UP_STATE);
        } else {
            setState(DISABLED_STATE);
        }
    }

    protected function mouseDown (event :MouseEvent) :void
    {
        _mouseOver = true;
        if (_enabled) {
            setState(DOWN_STATE);
        }
    }

    protected function mouseUp (event :MouseEvent) :void
    {
        if (_enabled) {
            setState(_mouseOver ? OVER_STATE : UP_STATE);
        }
    }

    protected function mouseOver (event :MouseEvent) :void
    {
        _mouseOver = true;
        if (_enabled) {
            setState(OVER_STATE);
        }
    }

    protected function mouseOut (event :MouseEvent) :void
    {
        _mouseOver = false;
        if (_enabled) {
            setState(UP_STATE);
        }
    }

    protected function getState () :int
    {
        if (STATES.indexOf(_mc.currentFrame) < 0) {
            log.warning("Undefined state! [" + _mc.currentFrame + "]");
            return -1;
        }

        return _mc.currentFrame;
    }

    protected function setState (state :int) :void
    {
        _mc.gotoAndStop(state);
        _mc.buttonMode = state != DISABLED_STATE;
    }
    
    private static const log :Log = Log.getLog(MovieClipButton);

    protected static const UP_STATE :int = 1;
    protected static const OVER_STATE :int = 2;
    protected static const DOWN_STATE :int = 3;
    protected static const DISABLED_STATE :int = 4;
    protected static const STATES :Array =
        [ UP_STATE, OVER_STATE, DOWN_STATE, DISABLED_STATE ];

    protected var _mc :MovieClip;
    protected var _enabled :Boolean = true;
    protected var _mouseOver :Boolean = false;
}
}
