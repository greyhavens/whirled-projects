package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.resource.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class PlasmaBullet extends SceneObject
{
    public static const RADIUS :Number = 6;
    public static const GROUP_NAME :String = "PlasmaBullet";
    
    public function PlasmaBullet ()
    {
        var image :ImageResourceLoader = ResourceManager.instance.getResource("plasma") as ImageResourceLoader;
        
        var bitmap :Bitmap = image.createBitmap();
        bitmap.x = -(bitmap.width / 2);
        bitmap.y = -(bitmap.height / 2);
        
        _sprite.addChild(bitmap);
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