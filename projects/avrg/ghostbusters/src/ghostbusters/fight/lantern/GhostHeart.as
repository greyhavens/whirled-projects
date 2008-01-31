package ghostbusters.fight.lantern {

import com.threerings.util.Name;
import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;

public class GhostHeart extends SceneObject
{
    public function GhostHeart (radius :Number)
    {
        _radius = radius;
        
        var heart :DisplayObject = (ResourceManager.instance.getResource("heart") as ImageResourceLoader).createBitmap();
        heart.scaleX = (_radius * 2) / heart.width;
        heart.scaleY = (_radius * 2) / heart.height;
        
        heart.x = -(heart.width / 2);
        heart.y = -(heart.height / 2);
        
        _sprite = new Sprite();
        _sprite.addChild(heart);
        
        this.setHeartbeatDelay(BASE_DELAY);
    }

    
    protected function setHeartbeatDelay (delay :Number) :void
    {
        this.scaleX = 1;
        this.scaleY = 1;
        
        var task :RepeatingTask = new RepeatingTask();
        task.addTask(ScaleTask.CreateEaseIn(BEAT_SCALE, BEAT_SCALE, 0.25));
        task.addTask(ScaleTask.CreateEaseOut(1, 1, 0.25));
        task.addTask(new TimedTask(delay));
        
        this.removeAllTasks();
        this.addTask(task);
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite;
    protected var _radius :Number;
    
    protected static const BEAT_SCALE :Number = 1.2;
    protected static const BASE_DELAY :Number = 0.6;
}

}