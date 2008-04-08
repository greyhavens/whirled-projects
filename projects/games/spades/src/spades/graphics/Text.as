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

    /** Initialization constant for a huge standard text field. */
    public static const HUGE :int = 2;

    /** Create a new standard text field of the given size. */
    public function Text(
        size :int = SMALL, 
        foreColor :uint = 0xFFFFFF, 
        backColor :uint = 0x000000,
        italic :Boolean = false)
    {
        _size = size;

        autoSize = TextFieldAutoSize.CENTER;
        
        var params :Array = FORMAT_PARAMS[size];
        defaultTextFormat = createFormat(params[0], foreColor, italic);
        selectable = false;
        x = 0;
        y = 0;

        params = OUTLINE_PARAMS[size];

        filters = [ createGlow(params[0], params[1], backColor) ];
    }

    public function rightJustify () :void
    {
        autoSize = TextFieldAutoSize.RIGHT;
    }

    public function leftJustify () :void
    {
        autoSize = TextFieldAutoSize.LEFT;
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

    /** Access the vertical bottom of the text field. Unlike using an expression of like 
     *  "y = -text.textHeight", the equivalent "bottomY = 0" does not depend on the current 
     *  contents of the text property. */
    public function set bottomY (value :Number) :void
    {
        y = value - effectiveTextHeight;
    }

    /** Access the vertical bottom of the text field. */
    public function get bottomY () :Number
    {
        return y + effectiveTextHeight;
    }

    /** Access the effective text height for use when centering vertically. */
    public function get effectiveTextHeight () :Number
    {
        return EFFECTIVE_SIZES[_size];
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

    protected static function createFormat (
        size :int, color :uint, italic :Boolean) :TextFormat
    {
        return new TextFormat("_sans", size, color, false, italic, false, 
            "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
    }

    protected static function createGlow (
        alpha :Number, size :int, color :uint) :GlowFilter
    {
        return new GlowFilter(color, alpha, size, size, 4);
    }

    protected static const FORMAT_PARAMS :Array = [[12], [14], [18]];
    protected static const OUTLINE_PARAMS :Array = [[.5, 3], [.7, 3], [.7, 3]]
    protected static const EFFECTIVE_SIZES :Array = [18, 20, 23];
}

}
