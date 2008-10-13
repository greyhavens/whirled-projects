package ghostbusters.client.fight.ouija
{
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.objects.*;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.tasks.*;
    
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    import ghostbusters.client.fight.common.*;
    
    public class IraqCursor extends SceneObject
    {
        public function IraqCursor(board :InteractiveObject, cursor :MovieClip)
        {
            _board = board;

//            var swf :SwfResource = (ResourceManager.instance.getResource("iraq.board") as SwfResource);
//            var soldierClass :Class = swf.getClass("cursor");
//            trace(swf.resourceName);
//            var soldier :MovieClip = new soldierClass();
            
            
//            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("iraq.board"));
            
//            modeSprite.addChild(swfRoot);
//            var soldier :MovieClip = MovieClip(swfRoot["cursor"]);
            
            cursor.x = 0;
            cursor.y = 0;
            _sprite.addChild(cursor); 
            
            
        // add the image, aligned by the center of its viewier
//        _cursorImage = ImageResource.instantiateBitmap("ouija.planchette");
//        _cursorImage.x = -CENTER.x;
//        _cursorImage.y = -CENTER.y;
//        _sprite.addChild(_cursorImage);

        _sprite.mouseEnabled = false;
        _sprite.mouseChildren = false;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function addedToDB () :void
    {
        _board.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved, false, 0, true);
        _sprite.x = _board.mouseX;
        _sprite.y = _board.mouseY;


        /*_board.addEventListener(MouseEvent.ROLL_OUT, mouseOut, false, 0, true);
        _board.addEventListener(MouseEvent.ROLL_OVER, mouseOver, false, 0, true);

        if (_board.hitTestPoint(_board.mouseX, _board.mouseY)) {
            CursorManager.hideCursor();
        } else {
            CursorManager.showCursor();
        }*/
    }

    protected function mouseMoved (e :MouseEvent) :void
    {
        this.updateLocation(_board.mouseX, _board.mouseY);
        //trace(_board.mouseX, _board.mouseY);
    }

    protected function mouseOut (e :MouseEvent) :void
    {
        //CursorManager.showCursor();
    }

    protected function mouseOver (e :MouseEvent) :void
    {
        //CursorManager.hideCursor();
    }

    protected function updateLocation (localX :Number, localY :Number) :void
    {
        _sprite.x = localX;
        _sprite.y = localY;
//        trace(_sprite.x + ", " + _sprite.y);
    }

    protected var _board :InteractiveObject;
    protected var _sprite :Sprite = new Sprite();
//    protected var _cursorImage :Bitmap;

//    protected static const CENTER :Vector2 = new Vector2(26, 25);

    }
}