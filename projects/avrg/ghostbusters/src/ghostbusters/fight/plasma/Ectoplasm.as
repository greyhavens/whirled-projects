package ghostbusters.fight.plasma {
    
import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.tasks.RepeatingTask;
import com.whirled.contrib.core.tasks.RotationTask;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Ectoplasm extends SceneObject
{
    public static const RADIUS :int = 20
    
    public function Ectoplasm ()
    {
        var bitmap :Bitmap = new Content.IMAGE_ECTOPLASM();
        //bitmap.x = 16;
        //bitmap.y = 16;
        _sprite.addChild(bitmap);
        
        var swirlTask :RepeatingTask = new RepeatingTask();
        swirlTask.addTask(new RotationTask(360, 1));
        swirlTask.addTask(new RotationTask(0));
        
        this.addTask(swirlTask);
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite = new Sprite();
    
}

}