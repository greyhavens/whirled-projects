package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.quest.QuestDesc;

public class QuestAddedNotification extends SceneObject
{
    public function QuestAddedNotification (quest :QuestDesc)
    {
        _sprite = new Sprite();

        var text :String = '"' + quest.displayName + '" added!';
        var tf :TextField = TextBits.createText(text, 3, 0, 0x0000ff);
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
