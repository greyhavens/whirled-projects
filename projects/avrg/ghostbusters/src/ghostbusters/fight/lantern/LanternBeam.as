package ghostbusters.fight.lantern {
    
import com.whirled.contrib.core.Vector2;
import com.whirled.contrib.core.objects.SceneObject;

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class LanternBeam extends SceneObject
{
    public function LanternBeam (radius :Number, lightSource :Vector2, board :InteractiveObject)
    {
        _radius = radius;
        _lightSource = lightSource;
        
        _sprite = new Sprite();
        _sprite.blendMode = BlendMode.ERASE; // erase the background
        
        board.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoved, false, 0, true);
    }
    
    protected function onMouseMoved (e :MouseEvent) :void
    {
        this.drawAt(e.localX, e.localY);
    }
    
    protected function drawAt (x :Number, y :Number) :void
    {
        _sprite.graphics.clear();
        
        _sprite.graphics.beginFill(COLOR);
        
        // draw the circle
        _sprite.graphics.drawCircle(x, y, _radius);
        
        // discover the two tangents to the circle that pass through our point
        
        // c: vector from light source to circle center
        var c :Vector2 = new Vector2(x - _lightSource.x, y - _lightSource.y);
        var cLen :Number = c.length;
        
        if (cLen > _radius) {
            var tangentLength :Number = Math.sqrt((cLen * cLen) - (_radius * _radius));
            var angle :Number = Math.asin(_radius / cLen);
            
            var p1 :Vector2 = c.getRotate(angle);
            p1.length = tangentLength;
            p1.add(_lightSource);
            
            var p2 :Vector2 = c.getRotate(-angle);
            p2.length = tangentLength;
            p2.add(_lightSource);
            
            // draw the beam
            _sprite.graphics.moveTo(_lightSource.x, _lightSource.y);
            _sprite.graphics.lineTo(p1.x, p1.y);
            _sprite.graphics.lineTo(p2.x, p2.y);
            _sprite.graphics.lineTo(_lightSource.x, _lightSource.y);
        }
        
        _sprite.graphics.endFill();
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite;
    protected var _radius :Number;
    protected var _lightSource :Vector2;
    
    protected static const COLOR :uint = 0xFFFF00;
    
}

}