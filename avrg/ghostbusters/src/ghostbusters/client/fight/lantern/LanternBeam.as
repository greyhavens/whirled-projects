package ghostbusters.client.fight.lantern {
    
import com.threerings.flash.Vector2;

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.GradientType;
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
        this.setLocation(e.localX, e.localY);
    }
    
    protected function setLocation (x :Number, y :Number) :void
    {
        _beamCenter.set(x, y);
        
        _sprite.graphics.clear();
        _sprite.graphics.lineStyle(0, 0, 0, true);
        
        var c :Vector2 = new Vector2(x - _lightSource.x, y - _lightSource.y); // c: vector from light source to circle center
        var cLen :Number = c.length;
        
        // draw the beam, unless the light source is contained
        // within the circle
        if (cLen > _radius) {
            
            // @TSC - Flash strangeness: using a gradient fill here prevents weird
            // artifacts at the edges of the shape
            
            //_sprite.graphics.beginFill(1, 0.5);
            _sprite.graphics.beginGradientFill(GradientType.LINEAR, [ 1 ], [ 0.5 ], [ 0 ]);
            
            var tangentLength :Number = Math.sqrt((cLen * cLen) - (_radius * _radius));
            var angle :Number = Math.asin(_radius / cLen);
            
            // create the two tangents to the circle that pass through our point
        
            var p1 :Vector2 = c.rotate(angle);
            p1.length = tangentLength;
            p1.addLocal(_lightSource);
            
            var p2 :Vector2 = c.rotate(-angle);
            p2.length = tangentLength;
            p2.addLocal(_lightSource);
            
            // draw the beam
            _sprite.graphics.moveTo(_lightSource.x, _lightSource.y);
            _sprite.graphics.lineTo(p1.x, p1.y);
            _sprite.graphics.lineTo(p2.x, p2.y);
            _sprite.graphics.lineTo(_lightSource.x, _lightSource.y);
        
            _sprite.graphics.endFill();
        }
        
        // draw the circle
        //_sprite.graphics.beginFill(1);
        _sprite.graphics.beginGradientFill(GradientType.LINEAR, [ 1 ], [ 1 ], [ 0 ]);
            
        _sprite.graphics.drawCircle(x, y, _radius);
        _sprite.graphics.endFill();
    }
    
    public function get beamCenter () :Vector2
    {
        return _beamCenter;
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite;
    protected var _radius :Number;
    protected var _lightSource :Vector2;
    protected var _beamCenter :Vector2 = new Vector2();
    
}

}