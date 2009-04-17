package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.quest.QuestDesc;

public class QuestCompletedNotification extends SceneObject
{
    public function QuestCompletedNotification (quest :QuestDesc)
    {
        var text :String = '"' + quest.displayName + '" completed!';
        var tf :TextField = TextBits.createText(text, 3, 0, 0x00ff00);
        tf.x = -tf.width * 0.5;
        tf.y = -tf.height * 0.5;
        _sprite.addChild(tf);

        addTask(new SerialTask(
            new TimedTask(2),
            new AlphaTask(0, 1),
            new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}

}
