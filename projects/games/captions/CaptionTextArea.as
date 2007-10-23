//
// $Id$

package {

import flash.events.Event;

import flash.filters.GlowFilter;

import flash.text.TextLineMetrics;

import mx.controls.TextArea;

public class CaptionTextArea extends TextArea
{
    public function CaptionTextArea ()
    {
        super();

        editable = true;

        setStyle("backgroundAlpha", 0);
        setStyle("textAlign", "center");
        setStyle("color", 0x000000);
        setProperties(2, 50, 16);

        addEventListener(Event.CHANGE, handleTextChanged);
    }

    override protected function initializationComplete () :void
    {
        super.initializationComplete();
        evalStyle();
    }

    public function setProperties (maxLines :int, maxFontSize :int, minFontSize :int) :void
    {
        _maxLines = maxLines;
        _maxFontSize = maxFontSize;
        _minFontSize = minFontSize;

        setStyle("fontSize", _maxFontSize);
        evalStyle();
    }

    public function setOutline (outline :Boolean) :void
    {
        _outline = outline;
        evalStyle();
    }

    /**
     * Evaluate the style for this component.
     */
    protected function evalStyle () :void
    {
        if (!processedDescriptors) {
            return;
        }

        // start out at 5 sizes larger than currently, in case they've deleted some text
        var size :int = Math.min(_maxFontSize, 5 + int(getStyle("fontSize")));
        setStyle("fontSize", size);
        textField.validateNow();
        while (textField.numLines > _maxLines) {
            var newSize :int = size - 1;
            if (newSize < _minFontSize) {
                // if we're already at the smallest size and there are too many lines,
                // chop off the last letter
                // WHY THE FLYING FUCK DOES just text eval to "" here? Why do I have to acces
                // the textField's text?
                textField.text = textField.text.slice(0, -1);

            } else {
                setStyle("fontSize", newSize);
                size = newSize;
            }
            textField.validateNow();
        }

        // now set the amount of glow based on the size
        if (_outline) {
            var outlineSize :int = Math.max(1, 
                int(5 * (size - _minFontSize) / (_maxFontSize - _minFontSize)));
            textField.filters = _outline ? [ new GlowFilter(0xFFFFFF, 1, 4, 4, 255) ] : null;

        } else {
            textField.filters = null;
        }
    }

    protected function handleTextChanged (event :Event) :void
    {
        evalStyle();
    }

    protected var _lastText :String = "";

    protected var _maxLines :int = 2;

    protected var _outline :Boolean = true;

    protected var _maxFontSize :int = 50;

    protected var _minFontSize :int = 16;
}
}
