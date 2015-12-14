package joingame.view
{
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.tasks.LocationTask;
    import com.whirled.contrib.simplegame.tasks.ParallelTask;
    import com.whirled.contrib.simplegame.tasks.ScaleTask;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    public class ElimatedOpponentsView extends SceneObject
    {
        public function ElimatedOpponentsView()
        {
            _sprite = new Sprite();
            _sprite.graphics.lineStyle(1, 0x33cc00);
            _sprite.graphics.drawRect(0,0,100, 80);
            
            _spaceForEachHeadshot = 50;
            _currentHeadshotScale = 0.3;
            _headshots = new Array();
            
            
            
        }


        public function addPlayerHeadShot( headshot: DisplayObject) :void
        {
            var sceneObject :SimpleSceneObject = new SimpleSceneObject(headshot);
            db.addObject(sceneObject, _sprite);
            
            var locationTask :LocationTask = LocationTask.CreateEaseOut( getWidthOfHeadshots(), 0, 1.0);
            var scaleTask :ScaleTask = new ScaleTask( _currentHeadshotScale, _currentHeadshotScale, 1.0);
            var parallelTask :ParallelTask = new ParallelTask( locationTask, scaleTask);
            sceneObject.addTask( parallelTask);
            _headshots.push( sceneObject );
            
        }

        override public function get displayObject () :DisplayObject
        {
            return _sprite;
        }
        
        
        
        protected function getWidthOfHeadshots() :int
        {
            
            return _headshots.length * _spaceForEachHeadshot;
//            var currentWidth :int = 0;
//            for each (var headshot :SceneObject in _headshots) {
//                currentWidth += headshot.displayObject.width + 1;
//            }
//            return currentWidth;
        }
        
        

    
        protected var _spaceForEachHeadshot :int;
        protected var _sprite :Sprite;
        protected var _headshots :Array;
        protected var _currentHeadshotScale :Number;

    }
}