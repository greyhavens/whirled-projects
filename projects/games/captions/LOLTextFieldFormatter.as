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

import com.threerings.util.Log;

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
     *
     * @param callback a function to call after we've made adjustments to the field.
     *                  function (field :TextField) :void
     */
    public function watch (field :TextField, callback :Function = null) :void
    {
        field.addEventListener(Event.CHANGE, handleChange);
        field.addEventListener(TextEvent.TEXT_INPUT, handleTextInput);
        field.addEventListener(FocusEvent.FOCUS_IN, handleFocusIn);
        field.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);

        _callbacks[field] = callback;

        format(field);
    }

    /**
     * Evaluate the style.
     */
    protected function evalStyle (field :TextField, goBig :Boolean = false) :void
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
                // let's prune ends off the text
                var text :String = field.text;
                if (text.length > 0) {
                    text = text.substr(0, text.length - 1);
                    field.text = text; // thankfully, this doesn't seem to trigger another CHANGE
                } else {
                    Log.dumpStack();
                    break;
                }
                break;
            }
        }

//        trace("text w/h: " + field.textWidth + ", " + field.textHeight);

//        trace("(" + goBig + ", " + field.numLines + ") Banged size to :" + size);

        var outlineSize :int = Math.max(1,
            int(5 * (size - _minFontSize) / (_maxFontSize - _minFontSize)));
        field.filters = [ new GlowFilter(0xFFFFFF, 1, 4, 4, 255) ];

        // now notfiy
        var fn :Function = _callbacks[field] as Function;
        if (fn != null) {
            fn(field);
        }
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
        trace("Got change");
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

        event.updateAfterEvent();
    }

    protected var _fontFamily :String;

    protected var _maxLines :int;

    protected var _maxFontSize :int;

    protected var _minFontSize :int;

    /* Maps a watched TextField to the last text we saw in handleChange. */
    protected var _lastText :Dictionary = new Dictionary(true);

    /* Maps a watched TextField to the callback function. */
    protected var _callbacks :Dictionary = new Dictionary(true);
}
}
