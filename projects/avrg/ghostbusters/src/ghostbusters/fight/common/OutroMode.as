package ghostbusters.fight.common {

import com.whirled.contrib.core.AppMode;

public class OutroMode extends AppMode
{
    public function OutroMode (success :Boolean)
    {
        this.addObject(new OutroObject(success), this.modeSprite);
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

class OutroObject extends SceneObject
{
    public function OutroObject (success :Boolean)
    {
        // create a rectangle
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0x000000);
        rect.graphics.drawRect(0, 0, 296, 223);
        rect.graphics.endFill();

        _sprite.addChild(rect);

        // create the text
        var textField :TextField = new TextField();
        textField.textColor = 0xFFFFFF;
        textField.defaultTextFormat.size = 20;
        textField.text = (success ? "SUCCESS!" : "FAILURE!");
        textField.width = textField.textWidth + 5;
        textField.height = textField.textHeight + 3;

        // center it
        textField.x = (rect.width / 2) - (textField.width / 2);
        textField.y = (rect.height / 2) - (textField.height / 2);

        _sprite.addChild(textField);

        // create a timer to pop the mode
        var task :SerialTask = new SerialTask();
        task.addTask(new TimedTask(MODE_TIMER));
        task.addTask(new FunctionTask(MainLoop.instance.popMode));
        this.addTask(task);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite = new Sprite();

    protected static const MODE_TIMER :Number = 2;
}
