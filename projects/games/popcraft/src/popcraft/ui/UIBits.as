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
    public static function createButton (text :String) :SimpleButton
    {
        var button :SimpleButton = new SimpleButton();
        button.upState = makeButtonFace(FACE_UP, text);
        button.overState = makeButtonFace(FACE_OVER, text);
        button.downState = makeButtonFace(FACE_DOWN, text);
        button.hitTestState = button.upState;

        return button;
    }

    protected static function makeButtonFace (face :int, text :String) :DisplayObject
    {
        var buttonUi :MovieClip = SwfResource.instantiateMovieClip("ui", "button_UI");

        var tf :TextField = buttonUi["button_text"];
        tf.multiline = false;
        tf.wordWrap = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
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
