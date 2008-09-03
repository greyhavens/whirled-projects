package {

import flash.text.TextField;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

public class MobSprite extends Sprite
{
    public function MobSprite (id :String)
    {
        _text = new TextField();
        addChild(_text);

        _text.text = id;
        _text.selectable = false;
        _text.autoSize = TextFieldAutoSize.CENTER;
        _text.x = -_text.width / 2;
        _text.y = -_text.height / 2;

        graphics.beginFill(0x7f7fff);
        graphics.drawRect(-10, -5, 20, 10);
        graphics.endFill();

        scaleX = 3;
        scaleY = 3;
    }

    protected var _text :TextField;
}

}
