package ghostbusters.fight.common {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.tasks.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class WinLoseNotification extends SceneObject
{
    public static const NAME :String = "WinLoseNotification";
    
    public static function create (success :Boolean, parent :DisplayObjectContainer) :void
    {
        var notification :WinLoseNotification = new WinLoseNotification(success);
        notification.animate();
        
        // center on game
        notification.x = (MicrogameConstants.GAME_WIDTH / 2) - (notification.width / 2);
        notification.y = (MicrogameConstants.GAME_HEIGHT / 2) - (notification.height / 2);
        
        MainLoop.instance.topMode.addObject(notification, parent);
    }
    
    public static function get isPlaying () :Boolean
    {
        return (null != MainLoop.instance.topMode.getObjectNamed(NAME));
    }
    
    public function WinLoseNotification (success :Boolean)
    {
        _success = success;
        
        var label :TextField = new TextField();
        label.text = (success ? "You Win!" : "You Lose!");
        label.textColor = (success ? 0x0000FF : 0xFF0000);
        label.autoSize = TextFieldAutoSize.CENTER;
        
        var rect :Sprite = new Sprite();
        rect.graphics.beginFill(success ? 0xFFFFFF : 0xFFFF00);
        rect.graphics.drawRect(0, 0, label.width + 2, label.height + 2);
        rect.graphics.endFill();
        
        // center the label on the rect
        label.x = (rect.width / 2) - (label.width / 2);
        label.y = (rect.height / 2) - (label.height / 2);
        
        rect.addChild(label);
        
        // center the rect on the sprite
        rect.x = -(rect.width / 2);
        rect.y = -(rect.height / 2);
        
        _sprite = new Sprite();
        _sprite.addChild(rect);
    }
    
    public function animate () :void
    {
        var anim :SerialTask = new SerialTask();
        anim.addTask(ScaleTask.CreateEaseIn(0.8, 0.8, 1));
        anim.addTask(ScaleTask.CreateEaseOut(3, 3, 2));
        anim.addTask(new TimedTask(2));
        anim.addTask(new SelfDestructTask());
        
        this.addTask(anim);
    }
    
    override public function get objectName () :String
    {
        return NAME;
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _success :Boolean;
    protected var _sprite :Sprite;
    
}

}