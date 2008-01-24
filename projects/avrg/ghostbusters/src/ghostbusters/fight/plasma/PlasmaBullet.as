package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class PlasmaBullet extends SceneObject
{
    public static const RADIUS :Number = 6;
    public static const GROUP_NAME :String = "PlasmaBullet";
    
    public function PlasmaBullet ()
    {
        var image :Bitmap = new Bitmap(ResourceManager.instance.getImage("image_plasma"));
        image.x = -(image.width / 2);
        image.y = -(image.height / 2);
        
        _sprite.addChild(image);
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