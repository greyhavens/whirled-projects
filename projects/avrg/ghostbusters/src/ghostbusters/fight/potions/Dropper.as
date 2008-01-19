package ghostbusters.fight.potions {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.util.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Dropper extends SceneObject
{
    public function Dropper (color :uint)
    {
        _color = color;
        
        // add the dropper image
        _sprite.addChild(new Content.IMAGE_DROPPER);
        
        // add the colored "dropper bottom"
        var bottomBitmap :Bitmap = ImageTool.createTintedBitmap(
            new Content.IMAGE_DROPPERBOTTOM,
            Colors.getScreenColor(color));
            
        bottomBitmap.x = DROPPER_BOTTOM_LOC.x;
        bottomBitmap.y = DROPPER_BOTTOM_LOC.y;
        
        _sprite.addChild(bottomBitmap);
    }
    
    public function get color () :uint
    {
        return _color;
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _color :uint;
    protected var _sprite :Sprite = new Sprite();
    
    protected static const DROPPER_BOTTOM_LOC :Vector2 = new Vector2(7, 20);
    
}

}