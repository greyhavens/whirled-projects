package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.quest.*;

public class ActivityAddedNotification extends SceneObject
{
    public function ActivityAddedNotification (activity :ActivityDesc)
    {
        _sprite = new Sprite();
        var text :String = activity.loc.displayName + ": " + activity.displayName + " unlocked!";
        var tf :TextField = TextBits.createText(text, 3, 0, 0xff00ff);
        _sprite.addChild(tf);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}

}
