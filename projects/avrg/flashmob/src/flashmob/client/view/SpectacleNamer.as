package flashmob.client.view {

import com.threerings.flash.TextFieldUtil;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;

import flashmob.client.*;
import flashmob.util.SpriteUtil;

public class SpectacleNamer extends DraggableObject
{
    public function SpectacleNamer (namedCallback :Function)
    {
        _sprite = SpriteUtil.createSprite(true, false);
        _draggableObj = SpriteUtil.createSprite(false, true);
        _sprite.addChild(_draggableObj);

        var tf :TextField = new TextField();
        UIBits.initTextField(tf, "Name Your Spectacle:", 1.3, 0, 0xFFFFFF);
        tf.x = MARGIN;
        tf.y = (HEIGHT - tf.height) * 0.5;
        _sprite.addChild(tf);

        var input :TextField = new TextField();
        input.type = TextFieldType.INPUT;
        input.text = "Miracular Spectaculous";
        input.setSelection(0, input.text.length - 1);
        input.background = true;
        input.backgroundColor = 0xFFFFFF;
        input.textColor = 0x000000;
        input.multiline = false;
        input.selectable = true;
        input.width = 200;
        input.height = 17;
        input.scaleX = input.scaleY = 1.3;
        input.autoSize = TextFieldAutoSize.NONE;
        input.x = tf.x + tf.width + 5;
        input.y = (HEIGHT - input.height) * 0.5;
        _sprite.addChild(input);

        TextFieldUtil.setFocusable(input);

        var okButton :SimpleButton = UIBits.createButton("OK", 1.5);
        okButton.x = input.x + input.width + 5;
        okButton.y = (HEIGHT - okButton.height) * 0.5;
        _sprite.addChild(okButton);

        registerOneShotCallback(okButton, MouseEvent.CLICK,
            function (...ignored) :void {
                namedCallback(input.text);
                destroySelf();
            });

        var g :Graphics = _draggableObj.graphics;
        g.lineStyle(2, 0);
        g.beginFill(0, 0.8);
        g.drawRoundRect(0, 0, _sprite.width + (MARGIN * 2), HEIGHT, 15, 15);
        g.endFill();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function get draggableObject () :InteractiveObject
    {
        return _draggableObj;
    }

    protected var _sprite :Sprite;
    protected var _draggableObj :Sprite;

    protected static const HEIGHT :Number = 60;
    protected static const MARGIN :Number = 10;
}

}
