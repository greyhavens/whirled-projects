package ghostbusters.fight.common {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

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
        
        // create a timer object
        MainLoop.instance.topMode.addObject(new WinLoseTimer(NAME, 1.5));
        
    }
    
    public static function get isPlaying () :Boolean
    {
        return (null != MainLoop.instance.topMode.getObjectNamed(NAME));
    }
    
    public function WinLoseNotification (success :Boolean)
    {
        _success = success;
        
        var textArray :Array = (success ? WIN_TEXT : LOSE_TEXT);
        var text :String = textArray[Rand.nextIntRange(0, textArray.length, Rand.STREAM_COSMETIC)];
        
        var label :TextField = new TextField();
        label.text = text;
        label.textColor = (success ? 0xFFFFFF : 0xFF0000);
        label.autoSize = TextFieldAutoSize.CENTER;
        label.scaleX = 4;
        label.scaleY = 4;
        
        _sprite = new Sprite();
        _sprite.graphics.beginFill(success ? 0x000000 : 0xFFFF00);
        _sprite.graphics.drawRect(0, 0, MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT);
        _sprite.graphics.endFill();
        
        // center the label on the rect
        label.x = (_sprite.width / 2) - (label.width / 2);
        label.y = (_sprite.height / 2) - (label.height / 2);
        
        _sprite.addChild(label);
        
        _sprite.mouseEnabled = false;
        _sprite.mouseChildren = false;
    }
    
    public function animate () :void
    {
        /*var anim :SerialTask = new SerialTask();
        anim.addTask(ScaleTask.CreateEaseIn(0.8, 0.8, 1));
        anim.addTask(ScaleTask.CreateEaseOut(3, 3, 2));
        anim.addTask(new SelfDestructTask());
        
        this.addTask(anim);*/
        
        //this.addTask(After(1.5, new SelfDestructTask()));
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _success :Boolean;
    protected var _sprite :Sprite;
    
    protected static const WIN_TEXT :Array = [
        "*POW*!",
        "*BIFF*!",
        "*ZAP*!",
        "*SMACK*!",
    ];
    
    protected static const LOSE_TEXT :Array = [
        "oof",
        "ouch",
        "argh",
        "agh",
    ];
    
}

}

import com.whirled.contrib.core.SimObject;
import com.whirled.contrib.core.tasks.*;

class WinLoseTimer extends SimObject
{
    public function WinLoseTimer (name :String, time :Number)
    {
        _name = name;
        
        this.addTask(After(time, new SelfDestructTask()));
    }
    
    override public function get objectName () :String { return _name; }
    
    protected var _name :String;
}