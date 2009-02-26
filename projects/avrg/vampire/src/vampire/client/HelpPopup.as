package vampire.client
{
    import com.whirled.contrib.simplegame.objects.SceneObject;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;

    public class HelpPopup extends SceneObject
    {
        public function HelpPopup()
        {
            super();
            _sceneObjectSprite = new DraggableSprite(ClientContext.ctrl, NAME);
            _sceneObjectSprite.init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
            _sceneObjectSprite.x = 20;
            _sceneObjectSprite.y = 20;
            
            _hudHelp = ClientContext.instantiateMovieClip("HUD", "popup_help", true);
            _sceneObjectSprite.addChild( _hudHelp );
            _hudHelp.gotoAndStop(1);
            
        }
        
        override public function get displayObject () :DisplayObject
        {
            return _sceneObjectSprite;
        }
        
        override public function get objectName () :String
        {
            return NAME;
        }
        
        protected var _hudHelp :MovieClip;
        protected var _sceneObjectSprite :DraggableSprite;
        
        public static const NAME :String = "HelpPopup";
        
    }
}