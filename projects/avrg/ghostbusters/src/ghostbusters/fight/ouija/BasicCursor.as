package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

/**
 * This should almost certainly be called "Planchette" instead of "Cursor", but who wants to type that word a million times?
 */
public class BasicCursor extends SceneObject
{
    public function BasicCursor (board :InteractiveObject)
    {
        _board = board;

        // add the image, aligned by the center of its viewier
        _cursorImage = new Content.IMAGE_PLANCHETTE();
        _cursorImage.x = -CENTER.x;
        _cursorImage.y = -CENTER.y;
        _sprite.addChild(_cursorImage);

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
    }

    protected var _board :InteractiveObject;
    protected var _sprite :Sprite = new Sprite();
    protected var _cursorImage :Bitmap;

    protected static const CENTER :Vector2 = new Vector2(26, 25);
}

}
