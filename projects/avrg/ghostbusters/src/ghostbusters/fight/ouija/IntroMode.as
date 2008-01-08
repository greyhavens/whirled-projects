package ghostbusters.fight.ouija {

import com.whirled.contrib.core.AppMode;

public class IntroMode extends AppMode
{
    public function IntroMode (word :String)
    {
        this.addObject(new IntroObject(word), this.modeSprite);
    }
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;
import ghostbusters.fight.ouija.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.text.TextField;

class IntroObject extends SceneObject
{
    public function IntroObject (introText :String)
    {
        // create a rectangle
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0x000000);
        rect.graphics.drawRect(0, 0, 280, 222);
        rect.graphics.endFill();

        _sprite.addChild(rect);

        // create the "Spell 'xyz'" text
        var textField :TextField = new TextField();
        textField.textColor = 0xFFFFFF;
        textField.defaultTextFormat.size = 20;
        textField.text = introText;
        textField.width = textField.textWidth + 5;
        textField.height = textField.textHeight + 3;

        // center it
        textField.x = (rect.width / 2) - (textField.width / 2);
        textField.y = (rect.height / 2) - (textField.height / 2);

        _sprite.addChild(textField);

        // fade the object and pop the mode
        var task :SerialTask = new SerialTask();
        task.addTask(new TimedTask(SHOW_TEXT_TIME));
        task.addTask(new AlphaTask(0, FADE_TIME));
        task.addTask(new FunctionTask(MainLoop.instance.popMode));
        this.addTask(task);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite = new Sprite();

    protected static const SHOW_TEXT_TIME :Number = 1;
    protected static const FADE_TIME :Number = 0.25;
}

