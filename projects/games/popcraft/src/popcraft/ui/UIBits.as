package popcraft.ui {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

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

    public static function createTextPanel (text :String, textScale :Number = 1, maxWidth :int = 0, border :Boolean = true) :Sprite
    {
        var multiline :Boolean = (maxWidth > 0);

        var panel :MovieClip = SwfResource.instantiateMovieClip("ui", "panel_UI");
        var tf :TextField = panel["panel_text"];

        // put the panel and text into a parent sprite to help alignment
        var sprite :Sprite = new Sprite();
        sprite.addChild(panel);
        sprite.addChild(tf);

        tf.multiline = multiline;
        tf.wordWrap = multiline;
        if (multiline) {
            tf.width = maxWidth;
        }
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.scaleX = textScale;
        tf.scaleY = textScale;
        tf.text = text;

        panel.scaleX = (tf.width + (PANEL_TEXT_H_BORDER * 2)) / panel.width;
        panel.scaleY = (tf.height + (PANEL_TEXT_V_BORDER * 2)) / panel.height;

        panel.x = 2;
        panel.y = 0;
        tf.x = (panel.width * 0.5) - (tf.width * 0.5);
        tf.y = (panel.height * 0.5) - (tf.height * 0.5);

        if (!border) {
            sprite.removeChild(panel);
        }

        return sprite;
    }

    protected static const PANEL_TEXT_H_BORDER :Number = 10;
    protected static const PANEL_TEXT_V_BORDER :Number = 3;

    public static function createButton (text :String, textScale :Number = 1) :SimpleButton
    {
        var button :SimpleButton = new SimpleButton();
        button.upState = makeButtonFace(FACE_UP, text, textScale);
        button.overState = makeButtonFace(FACE_OVER, text, textScale);
        button.downState = makeButtonFace(FACE_DOWN, text, textScale);
        button.hitTestState = button.upState;
        button.tabEnabled = false;

        return button;
    }

    protected static function makeButtonFace (face :int, text :String, textScale :Number) :DisplayObject
    {
        var buttonUi :MovieClip = SwfResource.instantiateMovieClip("ui", "button_UI");

        var tf :TextField = buttonUi["button_text"];
        tf.multiline = false;
        tf.wordWrap = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.scaleX = textScale;
        tf.scaleY = textScale;
        tf.text = text;

        // scale the frame to fit the text
        var frame :MovieClip = buttonUi["button_box"];
        var scaleX :Number = ((tf.width + BUTTON_H_MARGIN) / frame.width);
        var scaleY :Number = ((tf.height + BUTTON_Y_MARGIN) / frame.height);
        frame.scaleX = scaleX;
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
}

}
