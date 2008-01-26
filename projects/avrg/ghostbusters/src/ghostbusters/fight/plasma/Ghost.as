package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.resource.*;

import flash.display.DisplayObject;
import flash.display.Sprite;

public class Ghost extends SceneObject
{
    public function Ghost ()
    {
        var image :ImageResourceLoader = ResourceManager.instance.getResource("ghost") as ImageResourceLoader;
        _sprite.addChild(image.createBitmap());
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite = new Sprite();
    
}

}