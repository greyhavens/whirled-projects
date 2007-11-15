//
// $Id$

package {

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;

import flash.filters.GlowFilter;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flash.ui.Keyboard;

import flash.utils.Dictionary;

public class LOLTextFieldFormatter
{
    public function LOLTextFieldFormatter (
        fontFamily :String = "_sans", maxFontSize :int = 50, minFontSize :int = 16,
        maxLines :int = 2)
    {
        _fontFamily = fontFamily;
        _maxFontSize = maxFontSize;
        _minFontSize = minFontSize;
        _maxLines = maxLines;
    }

    /**
     * Format the specified field now.
     */
    public function format (field :TextField) :void
    {
        field.multiline = true;
        field.wordWrap = true;
        var fmt :TextFormat = new TextFormat(_fontFamily, _maxFontSize, 0x000000,
            null, null, null, null, null, TextFormatAlign.CENTER);
        updateFormat(field, fmt);

        evalStyle(field, true);
    }

    /**
     * Watch the specified field, re-formatting it when something changes.
     */
    public function watch (field :TextField) :void
    {
        field.addEventListener(Event.CHANGE, handleChange);
        field.addEventListener(TextEvent.TEXT_INPUT, handleTextInput);
        field.addEventListener(FocusEvent.FOCUS_IN, handleFocusIn);
        field.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);

        format(field);
    }

    /**
     * Evaluate the style return true if the text currently fits.
     */
    protected function evalStyle (field :TextField, goBig :Boolean = false) :Boolean
    {
        var format :TextFormat = field.getTextFormat();
        var size :int = int(format.size);
        if (goBig || format.size == null || size < _minFontSize) {
            format.size = size = _maxFontSize;
            updateFormat(field, format);
        }

        var doesFit :Boolean = true;
        while ((field.numLines > _maxLines) || (field.textHeight + 4 > field.height)) {
            if (size > _minFontSize) {
                size--;
                format.size = size;
                updateFormat(field, format);

            } else {
                doesFit = false;
                break;
            }
        }
//        trace("(" + goBig + ", " + field.numLines + ") Banged size to :" + size);

        var outlineSize :int = Math.max(1,
            int(5 * (size - _minFontSize) / (_maxFontSize - _minFontSize)));
        field.filters = [ new GlowFilter(0xFFFFFF, 1, 4, 4, 255) ];

        return doesFit;
    }

    protected function updateFormat (field :TextField, fmt :TextFormat) :void
    {
        field.defaultTextFormat = fmt;
        var len :int = field.length;
        if (len > 0) {
            field.setTextFormat(fmt, 0, len);
        }
        field.text = field.text;
    }

    protected function handleTextInput (event :TextEvent) :void
    {
        // Don't let the user press return
        if (event.text == "\n") {
            var field :TextField = event.currentTarget as TextField;
            // no returns if we're already at the max
            if (field.numLines >= _maxLines) {
                event.preventDefault();
            }
        }
    }

    protected function handleChange (event :Event) :void
    {
        var field :TextField = event.currentTarget as TextField;
        var curText :String = field.text;
        var lastText :String = _lastText[field];
        _lastText[field] = curText;

        var reEval :Boolean = (curText.length == 0) ||
            (curText.substr(0, curText.length - 1) != lastText);

        evalStyle(field, reEval);
    }

    protected function handleFocusIn (event :FocusEvent) :void
    {
        var field :TextField = event.currentTarget as TextField;
        evalStyle(field, true);
    }

    protected function handleKeyUp (event :KeyboardEvent) :void
    {
        var field :TextField = event.currentTarget as TextField;
        evalStyle(field, (event.keyCode == Keyboard.BACKSPACE));
    }

    protected var _fontFamily :String;

    protected var _maxLines :int;

    protected var _maxFontSize :int;

    protected var _minFontSize :int;

    protected var _lastText :Dictionary = new Dictionary(true);
}
}
