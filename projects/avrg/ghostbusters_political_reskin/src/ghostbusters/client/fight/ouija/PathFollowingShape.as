package ghostbusters.client.fight.ouija
{
    import com.threerings.flash.Vector2;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.tasks.SerialTask;
    
    import flash.display.Shape;
    
    public class PathFollowingShape extends SceneObject
    {
        public function PathFollowingShape(path :Array, shape :Shape, speed :Number = 0.1)
        {
            _path = path;
            _shape = shape;
            
        }
        
        public function start() :void
        {
            var serialTask :SerialTask = new SerialTask();
            var v :Vector2;
            
            var totalDistance :Number = 0;
            for(var k :int = 1; k < _path.length; k++) {
                var v1 :Vector2 = _path[k] as Vector2;
                var v2 :Vector2 = _path[k - 1] as Vector2;
                totalDistance += v1.
            }
            
            for each ( var v :Vector2 in path) {
                
            }
        }
        
        protected var _shape :Shape;
        protected var _path :Array;

    }
}