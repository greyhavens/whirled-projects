package joingame.view
{
    import com.whirled.contrib.simplegame.tasks.LocationTask;
    import com.whirled.contrib.simplegame.util.Interpolator;

    import com.threerings.util.Assert;

    import com.whirled.contrib.simplegame.SimObject;
    import com.whirled.contrib.simplegame.ObjectTask;
    import com.whirled.contrib.simplegame.util.Interpolator;
    import com.whirled.contrib.simplegame.util.MXInterpolatorAdapter;
    
    import flash.geom.Point;
    
    import mx.effects.easing.*;
    import flash.display.DisplayObject;
    import com.whirled.contrib.simplegame.components.LocationComponent;
    import com.whirled.contrib.simplegame.ObjectMessage;
    public class ChangableTargetLocationTask extends LocationTask
    {
        public function ChangableTargetLocationTask(x:Number, y:Number, time:Number=0, interpolator:Interpolator=null)
        {
            super(x, y, time, interpolator);
        }
        
        public static function CreateEaseIn (x :Number, y :Number, time :Number) :LocationTask
        {
            return new ChangableTargetLocationTask(
                x, y,
                time,
                new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
        }   
    
        
        override public function update (dt :Number, obj :SimObject) :Boolean
        {
            var lc :LocationComponent = (obj as LocationComponent);
            
            var changeable :ChangeableTargetLocation = (obj as ChangeableTargetLocation);
            
            if (null == lc || null == changeable) {
                throw new Error("LocationTask can only be applied to SimObjects that implement LocationComponent");
            }
    
            if (0 == _elapsedTime) {
                _fromX = lc.x;
                _fromY = lc.y;
            }
            
            _toX = changeable.targetX;
            _toY = changeable.targetY;
    
            _elapsedTime += dt;
    
            lc.x = _interpolator.interpolate(_fromX, _toX, _elapsedTime, _totalTime);
            lc.y = _interpolator.interpolate(_fromY, _toY, _elapsedTime, _totalTime);
    
            return (_elapsedTime >= _totalTime);
        }

    }
}