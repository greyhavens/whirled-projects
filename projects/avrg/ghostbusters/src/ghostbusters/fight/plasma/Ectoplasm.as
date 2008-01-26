package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Ectoplasm extends SceneObject
{
    public static const RADIUS :int = 10;
    public static const GROUP_NAME :String = "Ectoplasm";
    
    public function Ectoplasm ()
    {
        var image :ImageResourceLoader = ResourceManager.instance.getResource("ectoplasm") as ImageResourceLoader;
        var bitmap :Bitmap = image.createBitmap();
        
        bitmap.x = -(bitmap.width / 2);
        bitmap.y = -(bitmap.height / 2);
        _sprite.addChild(bitmap);
        
        var rotFrom :int = Rand.nextIntRange(-360, 360, Rand.STREAM_COSMETIC);
        var rotTo :int = (rotFrom > 0 ? rotFrom + 360 : rotFrom - 360);
        var rotTime :Number = Rand.nextNumberRange(2.5, 4.5, Rand.STREAM_COSMETIC);
        
        this.rotation = rotFrom;
        
        var swirlTask :RepeatingTask = new RepeatingTask();
        swirlTask.addTask(new RotationTask(rotTo, rotTime));
        swirlTask.addTask(new RotationTask(rotFrom));
        
        this.addTask(swirlTask);
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    override public function get objectGroups () :Array
    {
        return [ GROUP_NAME ];
    }
    
    protected var _sprite :Sprite = new Sprite();
    
}

}