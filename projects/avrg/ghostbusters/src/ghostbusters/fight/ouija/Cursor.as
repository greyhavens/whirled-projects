package ghostbusters.fight.ouija {
    
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

import ghostbusters.fight.core.AppMode;
import ghostbusters.fight.core.AppObject;
import ghostbusters.fight.core.Vector2;

/**
 * This should almost certainly be called "Planchette" instead of "Cursor", but who wants to type that word a million times?
 */
public class Cursor extends AppObject
{
    public function Cursor (board :Board)
    {
        _board = board;
        
        // add the image, aligned by the center of its viewier
        var image :Bitmap = new IMAGE_PLANCHETTE();
        image.x = -CENTER.x;
        image.y = -CENTER.y;
        _sprite.addChild(image);
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    override protected function addedToMode (mode :AppMode) :void
    {
        _board.interactiveObject.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
        this.updateLocation(_board.displayObject.mouseX, _board.displayObject.mouseY);
    }
    
    protected function mouseMoved (e :MouseEvent) :void
    {
        this.updateLocation(_board.displayObject.mouseX, _board.displayObject.mouseY);
    }
    
    protected function updateLocation (localX :Number, localY :Number) :void
    {
        _sprite.x = localX;
        _sprite.y = localY;
    }
    
    protected var _board :Board;
    protected var _sprite :Sprite = new Sprite();
    
    protected static const CENTER :Vector2 = new Vector2(26, 25);
    
    [Embed(source="../../../../rsrc/ouijaplanchette.png")]
    protected static const IMAGE_PLANCHETTE :Class;
}

}