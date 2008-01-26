package ghostbusters.fight.potions {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.util.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

public class Dropper extends SceneObject
{
    public function Dropper (color :uint, movie :MovieClip)
    {
        _color = color;
        _movie = movie;
        
        // apply tint
        _movie.liquid.filters = [ ImageTool.createTintFilter(Colors.getScreenColor(_color)) ];
        _movie.squeezer.filters = [ ImageTool.createTintFilter(Colors.getScreenColor(_color)) ];
        
        // show a glow when the dropper is rolled over
        _glow = new GlowFilter();
        _glow.color = 0x00FFFF;
        _glow.alpha = 0.5;
        _glow.strength = 8;
        _glow.knockout = false;
        
        _movie.addEventListener(MouseEvent.ROLL_OVER, showGlow, false, 0, true);
        _movie.addEventListener(MouseEvent.ROLL_OUT, hideGlow, false, 0, true);
    }
    
    public function get color () :uint
    {
        return _color;
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }
    
    protected function showGlow (e :MouseEvent) :void
    {
        _movie.filters = [ _glow ];
    }
    
    protected function hideGlow (e :MouseEvent) :void
    {
        _movie.filters = null;
    }
    
    protected var _color :uint;
    protected var _movie :MovieClip;
    protected var _glow :GlowFilter;
    
    protected static const DROPPER_BOTTOM_LOC :Vector2 = new Vector2(7, 20);
    
}

}