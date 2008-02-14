package popcraft.battle {
    
import com.threerings.flash.Vector2;

import com.whirled.contrib.core.objects.SceneObject;
import com.whirled.contrib.core.tasks.*;

import flash.display.DisplayObject;
import flash.display.Shape;

public class MissileView extends SceneObject
{
    public function MissileView (startLoc :Vector2, endLoc :Vector2, travelTime :Number)
    {
        _startLoc = startLoc.clone();
        
        _direction = endLoc.subtract(_startLoc);
        
        _totalDistance = _direction.length;
        
        _direction.length = 1;
        
        _travelTime = travelTime;
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _shape;
    }
    
    override protected function update (dt :Number) :void
    {
        if (_done) {
            return;
        }
        
        _elapsedTime += dt;
        _elapsedTime = Math.min(_elapsedTime, _travelTime);
        
        // draw a line from the start location to the missile's current location
        
        var distance :Number = _totalDistance * (_elapsedTime / _travelTime);
            
        var drawTo :Vector2 = _direction.scale(distance).addLocal(_startLoc);
        
        _shape.graphics.clear();
        _shape.graphics.lineStyle(1, COLOR);
        _shape.graphics.moveTo(_startLoc.x, _startLoc.y);
        _shape.graphics.lineTo(drawTo.x, drawTo.y);
        
        if (_elapsedTime == _travelTime) {
            
            // fade out and die
            this.addTask(new SerialTask(
                new AlphaTask(0, FADE_TIME),
                new SelfDestructTask()));
                
            _done = true;
        }
        
    }
    
    protected var _startLoc :Vector2;
    protected var _direction :Vector2; // unit vector
    
    protected var _totalDistance :Number;
    
    protected var _elapsedTime :Number = 0;
    protected var _travelTime :Number;
    
    protected var _done :Boolean;
    
    protected var _shape :Shape = new Shape();
    
    protected static const COLOR :uint = 0x000000;
    protected static const FADE_TIME :Number = 0.25;
    
}

}