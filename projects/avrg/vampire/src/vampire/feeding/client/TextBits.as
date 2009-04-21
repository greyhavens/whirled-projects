package vampire.feeding.client {

import com.whirled.contrib.simplegame.resource.*;

import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class TextBits
{
    public static const FONT_JUICE :int = 0;
    public static const FONT_GARAMOND :int = 1;
    public static const FONT_ARNO :int = 2;

    public static function createText (text :String, textScale :Number = 1, maxWidth :int = 0,
        textColor :uint = 0, align :String = "center", font :int = FONT_JUICE) :TextField
    {
        var tf :TextField = new TextField();
        initTextField(tf, text, textScale, maxWidth, textColor, align, font);

        return tf;
    }

    public static function initTextField (tf :TextField, text :String, textScale :Number,
        maxWidth :int, textColor :uint = 0, align :String = "center", font :int = FONT_JUICE) :void
    {
        var wordWrap :Boolean = (maxWidth > 0);

        tf.mouseEnabled = false;
        tf.selectable = false;
        tf.multiline = true;
        tf.wordWrap = wordWrap;
        tf.scaleX = textScale;
        tf.scaleY = textScale;
        // If this is not set to true, modifying the TextField's alpha won't work
        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;

        if (wordWrap) {
            tf.width = maxWidth / textScale;
        } else {
            tf.autoSize = TextFieldAutoSize.LEFT;
        }

        tf.text = text;

        var format :TextFormat = tf.defaultTextFormat;
        format.align = align;
        format.font = FONT_NAMES[font];
        format.bold = true;

        if (textColor > 0) {
            format.color = textColor;
        }

        tf.setTextFormat(format);

        if (wordWrap) {
            // if the text isn't as wide as maxWidth, shrink the TextField
            tf.width = tf.textWidth + TEXT_WIDTH_PAD;
            tf.height = tf.textHeight + TEXT_HEIGHT_PAD;
        }
    }

    protected static const TEXT_WIDTH_PAD :int = 5;
    protected static const TEXT_HEIGHT_PAD :int = 4;

    protected static const FONT_NAMES :Array = [
        "Juice ITC", "Adobe Garamond Pro", "Arno Pro Semibold"
    ];

    [Embed(source="../../../../rsrc/JUICE___.TTF", fontName="Juice ITC",
        unicodeRange="U+0020-U+007E")]
    protected static const JUICE_FONT :Class;

    [Embed(source="../../../../rsrc/AGaramondPro-Regular.otf", fontName="Adobe Garamond Pro",
        unicodeRange="U+0020-U+007E")]
    protected static const GARAMOND_FONT :Class;

    [Embed(source="../../../../rsrc/ArnoPro-LightDisplay.otf", fontName="Arno Pro Semibold",
        unicodeRange="U+0020-U+007E")]
    protected static const ARNO_FONT :Class;
}

}
