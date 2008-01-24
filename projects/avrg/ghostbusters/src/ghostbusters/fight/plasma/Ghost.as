package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

public class Ghost extends SceneObject
{
    public function Ghost ()
    {
        _sprite.addChild(new Bitmap(ResourceManager.instance.getImage("image_ghost")));
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite = new Sprite();
    
}

}