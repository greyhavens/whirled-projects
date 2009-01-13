package flashmob.client.view {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flashmob.util.SpriteUtil;

public class UIBits
{
    public static function initTextField (tf :TextField, text :String, textScale :Number,
        maxWidth :int, textColor :Number, align :String = TextFormatAlign.CENTER) :void
    {
        var wordWrap :Boolean = (maxWidth > 0);

        tf.mouseEnabled = false;
        tf.selectable = false;
        tf.multiline = true;
        tf.wordWrap = wordWrap;
        tf.scaleX = textScale;
        tf.scaleY = textScale;

        if (wordWrap) {
            tf.width = maxWidth / textScale;
        } else {
            tf.autoSize = TextFieldAutoSize.LEFT;
        }

        tf.text = text;

        if (wordWrap) {
            // if the text isn't as wide as maxWidth, shrink the TextField
            tf.width = tf.textWidth + TEXT_WIDTH_PAD;
            tf.height = tf.textHeight + TEXT_HEIGHT_PAD;
        }

        var format :TextFormat = tf.defaultTextFormat;
        format.align = align;

        if (textColor > 0) {
            format.color = textColor;
        }

        tf.setTextFormat(format);
    }

    protected static const TEXT_WIDTH_PAD :int = 5;
    protected static const TEXT_HEIGHT_PAD :int = 4;
}

}
