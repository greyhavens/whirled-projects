package ghostbusters.fight.plasma {
    
import com.whirled.contrib.core.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

public class Ghost extends SceneObject
{
    public function Ghost ()
    {
        _sprite.addChild(new Content.IMAGE_GHOST());
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite = new Sprite();
    
}

}