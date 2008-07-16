package popcraft.ui {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class UIBits
{
    public static function createFrame (width :Number, height :Number) :Sprite
    {
        var frame :MovieClip = SwfResource.instantiateMovieClip("ui", "frame_UI");
        frame.scaleX = width / frame.width;
        frame.scaleY = height / frame.height;

        var sprite :Sprite = new Sprite();
        sprite.addChild(frame);

        return sprite;
    }

    public static function createText (text :String, textScale :Number = 1, maxWidth :int = 0,
        textColor :uint = 0, align :String = TextFormatAlign.CENTER) :TextField
    {
        var textClip :MovieClip = SwfResource.instantiateMovieClip("ui", "text_UI");
        var tf :TextField = textClip["text"];
        textClip.removeChild(tf);

        initTextField(tf, text, textScale, maxWidth, textColor, align);

        return tf;
    }

    public static function createTitleText (text :String, textScale :Number = 1,
        maxWidth :int = 0, align :String = TextFormatAlign.CENTER) :TextField
    {
        var textClip :MovieClip = SwfResource.instantiateMovieClip("ui", "title_UI");
        var tf :TextField = textClip["title_text"];
        initTextField(tf, text, textScale, maxWidth, -1, align);

        return tf;
    }

    public static function createTextPanel (text :String, textScale :Number = 1,
        maxWidth :int = 0, textColor :uint = 0, align :String = TextFormatAlign.CENTER) :Sprite
    {
        if (maxWidth > 0) {
            // account for the panel border
            maxWidth = Math.max(1, maxWidth - (PANEL_TEXT_H_MARGIN * 2));
        }

        var tf :TextField = createText(text, textScale, maxWidth, textColor, align);

        var panel :MovieClip = SwfResource.instantiateMovieClip("ui", "panel_UI");

        panel.width = (tf.width + (PANEL_TEXT_H_MARGIN * 2));
        panel.height = (tf.height + (PANEL_TEXT_V_MARGIN * 2));
        panel.x = (panel.width * 0.5);
        panel.y = (panel.height * 0.5);
        tf.x = (panel.width * 0.5) - (tf.width * 0.5);
        tf.y = (panel.height * 0.5) - (tf.height * 0.5);

        var sprite :Sprite = new Sprite();
        sprite.addChild(panel);
        sprite.addChild(tf);

        return sprite;
    }

    protected static function initTextField (tf :TextField, text :String, textScale :Number,
        maxWidth :int, textColor :Number, align :String) :void
    {
        var wordWrap :Boolean = (maxWidth > 0);

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

    public static function createButton (text :String, textScale :Number = 1, width :Number = -1) :SimpleButton
    {
        var button :SimpleButton = new SimpleButton();
        button.upState = makeButtonFace(FACE_UP, text, textScale, width);
        button.overState = makeButtonFace(FACE_OVER, text, textScale, width);
        button.downState = makeButtonFace(FACE_DOWN, text, textScale, width);
        button.hitTestState = button.upState;
        button.tabEnabled = false;

        return button;
    }

    protected static function makeButtonFace (face :int, text :String, textScale :Number, width :Number) :DisplayObject
    {
        var buttonUi :MovieClip = SwfResource.instantiateMovieClip("ui", "button_UI");

        var tf :TextField = buttonUi["button_text"];
        tf.multiline = false;
        tf.wordWrap = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.scaleX = textScale;
        tf.scaleY = textScale;
        tf.text = text;

        var frame :MovieClip = buttonUi["button_box"];
        if (width < 0) {
            // scale the frame to fit the text
            var scaleX :Number = ((tf.width + BUTTON_H_MARGIN) / frame.width);
            frame.scaleX = scaleX;
        } else {
            // use an absolute width
            frame.width = width;
        }

        // scale the frame to fit the text height
        var scaleY :Number = ((tf.height + BUTTON_Y_MARGIN) / frame.height);
        frame.scaleY = scaleY;

        // Add the frame and text to a new sprite. Trying to align them
        // within button_UI is becoming more trouble than it's worth
        var sprite :Sprite = new Sprite();
        sprite.addChild(frame);
        sprite.addChild(tf);

        // center the frame and text
        frame.x = (frame.width * 0.5) + 1;
        frame.y = (frame.height * 0.5) - 1;
        tf.x = (frame.width * 0.5) - (tf.width * 0.5);
        tf.y = (frame.height * 0.5) - (tf.height * 0.5);

        switch (face) {
        case FACE_DOWN:
            sprite.x += 1;
            sprite.y += 1;
            // fall through to FACE_OVER

        case FACE_OVER:
            frame.filters = [ ColorMatrix.create().adjustContrast(0.3, 0.3, 0.3).createFilter() ];
            break;
        }

        return sprite;
    }

    protected static const FACE_UP :int = 0;
    protected static const FACE_OVER :int = 1;
    protected static const FACE_DOWN :int = 2;

    protected static const BUTTON_H_MARGIN :int = 23;
    protected static const BUTTON_Y_MARGIN :int = 15;

    protected static const TEXT_WIDTH_PAD :int = 5;
    protected static const TEXT_HEIGHT_PAD :int = 4;

    protected static const PANEL_TEXT_H_MARGIN :Number = 12;
    protected static const PANEL_TEXT_V_MARGIN :Number = 6;
}

}
