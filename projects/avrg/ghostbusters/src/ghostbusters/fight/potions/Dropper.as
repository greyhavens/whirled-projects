package ghostbusters.fight.potions {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.util.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class Dropper extends SceneObject
{
    public function Dropper (color :uint)
    {
        _color = color;
        
        // add the dropper image
        var image :Bitmap = new Content.IMAGE_DROPPER();
        _sprite.addChild(image);
        
        // add the colored "dropper bottom"
        var bottomBitmap :Bitmap = ImageTool.createTintedBitmap(
            new Content.IMAGE_DROPPERBOTTOM,
            Colors.getScreenColor(color));
            
        bottomBitmap.x = DROPPER_BOTTOM_LOC.x;
        bottomBitmap.y = DROPPER_BOTTOM_LOC.y;
        
        _sprite.addChild(bottomBitmap);
        
        // create a glow
        _glow = ImageUtil.createGlowBitmap(image, 0x00FFFF);
        _glow.visible = false;
        _sprite.addChild(_glow);
        
        _sprite.addEventListener(MouseEvent.ROLL_OVER, showGlow, false, 0, true);
        _sprite.addEventListener(MouseEvent.ROLL_OUT, hideGlow, false, 0, true);
    }
    
    public function get color () :uint
    {
        return _color;
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected function showGlow (e :MouseEvent) :void
    {
        _glow.visible = true;
    }
    
    protected function hideGlow (e :MouseEvent) :void
    {
        _glow.visible = false;
    }
    
    protected var _color :uint;
    protected var _sprite :Sprite = new Sprite();
    protected var _glow :DisplayObject;
    
    protected static const DROPPER_BOTTOM_LOC :Vector2 = new Vector2(7, 20);
    
}

}

import flash.display.BitmapData
import flash.display.Bitmap;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

class ImageUtil
{
    public static function createGlowBitmap (srcBitmap :Bitmap, color :uint) :Bitmap
    {
        // add a glow around the image
        var glowData :BitmapData = new BitmapData(
            srcBitmap.width + (GLOW_BUFFER * 2),
            srcBitmap.height + (GLOW_BUFFER * 2),
            true,
            0x00000000);

        var glowFilter :GlowFilter = new GlowFilter();
        glowFilter.color = color;
        glowFilter.alpha = 0.5;
        glowFilter.strength = 8;
        glowFilter.knockout = true;

        glowData.applyFilter(
            srcBitmap.bitmapData,
            new Rectangle(0, 0, srcBitmap.width, srcBitmap.height),
            new Point(GLOW_BUFFER, GLOW_BUFFER),
            glowFilter);

        var glowBitmap :Bitmap = new Bitmap(glowData);
        glowBitmap.x = srcBitmap.x - GLOW_BUFFER;
        glowBitmap.y = srcBitmap.y - GLOW_BUFFER;

        return glowBitmap;
    }

    protected static const GLOW_BUFFER :int = 7;
}