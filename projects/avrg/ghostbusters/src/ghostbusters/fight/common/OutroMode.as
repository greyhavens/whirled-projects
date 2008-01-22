package ghostbusters.fight.common {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;

public class OutroMode extends AppMode
{
    public function OutroMode (success :Boolean, beginNextGameCallback :Function)
    {
        var outro :OutroObject = new OutroObject(success);
        outro.alpha = 0;
        
        var outroTask :SerialTask = new SerialTask();
        outroTask.addTask(new TimedTask(TIME_PAUSEIN));
        outroTask.addTask(new AlphaTask(1, TIME_FADEIN));
        outroTask.addTask(new TimedTask(TIME_PAUSEOUT));
        outroTask.addTask(new FunctionTask(
            function () :void {
                MainLoop.instance.popMode(); // pop outro mode
                MainLoop.instance.popMode(); // pop game mode
                if (null != beginNextGameCallback) {
                    beginNextGameCallback(); // begin the next game
                }
            }
        ));
        
        outro.addTask(outroTask);
        
        this.addObject(outro, this.modeSprite);
    }
    
    protected static const TIME_PAUSEIN :Number = 1;
    protected static const TIME_FADEIN :Number = 0.5;
    protected static const TIME_PAUSEOUT :Number = 1;
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
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite = new Sprite();

    protected static const MODE_TIMER :Number = 2;
}
