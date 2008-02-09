package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.resource.*;

import flash.display.DisplayObject;
import flash.display.Sprite;

import ghostbusters.fight.common.*;

public class Ghost extends SceneObject
{
    public function Ghost ()
    {
        var image :ImageResourceLoader = Resources.instance.getImageLoader("plasma.ghost");
        _sprite.addChild(image.createBitmap());
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite = new Sprite();
    
}

}