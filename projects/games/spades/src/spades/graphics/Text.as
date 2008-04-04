package spades.graphics {

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.GlowFilter;

/** Standard text field for spades. */
public class Text extends TextField
{
    /** Initialization constant for a small standard text field. */
    public static const SMALL :int = 0;

    /** Initialization constant for a big standard text field. */
    public static const BIG :int = 1;

    /** Create a new standard text field of the given size. */
    public function Text(size :int=SMALL)
    {
        _size = size;

        autoSize = TextFieldAutoSize.CENTER;
        defaultTextFormat = FORMATS[size] as TextFormat;
        selectable = false;
        x = 0;
        y = 0;

        filters = [ OUTLINES[size] as GlowFilter ];
    }

    /** Access the vertical center of the text field. Unlike using an expression of like 
     *  "y = -text.textHeight / 2", the equivalent "centerY = 0" does not depend on the current 
     *  contents of the text property. */
    public function set centerY (value :Number) :void
    {
        y = value - effectiveTextHeight / 2;
    }

    /** Access the vertical center of the text field. */
    public function get centerY () :Number
    {
        return y + effectiveTextHeight / 2;
    }

    /** Access the effective text height for use when centering vertically. */
    public function get effectiveTextHeight () :Number
    {
        if (_size == SMALL) {
            return 16;
        }
        else {
            return 28;
        }
    }

    /** Utility function to truncate a name. */
    public static function truncName (name: String) :String
    {
        if (name.length > MAX_NAME_LENGTH) {
            name = name.substr(0, MAX_NAME_LENGTH) + "...";
        }
        return name;
    }

    protected var _size :int;

    protected static const MAX_NAME_LENGTH :int = 12;

    protected static function createFormat (size :int) :TextFormat
    {
        return new TextFormat("_sans", size, 0xFFFFFF, false, false, false, 
            "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
    }

    protected static function createGlow (
        alpha :Number, size :int) :GlowFilter
    {
        return new GlowFilter(0x000000, alpha, size, size, 255);
    }

    protected static const FORMATS :Array = [
        createFormat(12), 
        createFormat(18)];

    protected static const OUTLINES :Array = [
        createGlow(.7, 2), 
        createGlow(1, 4)];
}

}
