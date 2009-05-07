package vampire.fightproto.fight {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.client.SpriteUtil;
import vampire.fightproto.*;

public class EventText extends SceneObject
{
    public static const GOOD :int = 0;
    public static const NEUTRAL :int = 1;
    public static const BAD :int = 2;

    public function EventText (text :String, type :int, x :int, y :int)
    {
        _sprite = SpriteUtil.createSprite();

        var tf :TextField = TextBits.createText(text, 2, 0, COLORS[type]);
        tf.x = -tf.width * 0.5;
        tf.y = -tf.height * 0.5;
        _sprite.addChild(tf);

        this.x = x;
        this.y = y;

        addTask(new SerialTask(
            new TimedTask(0.75),
            new ParallelTask(
                LocationTask.CreateEaseIn(x, y - 20, 1),
                new AlphaTask(0, 1)),
            new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;;
    }

    protected var _sprite :Sprite;

    protected static const COLORS :Array = [ 0x00ff00, 0xffffff, 0xff0000 ];
}

}
