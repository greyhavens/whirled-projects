package ghostbusters.fight.ouija {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.BitmapData
import flash.display.Bitmap;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.filters.GlowFilter;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;
import flash.display.InteractiveObject;

/**
 * This should almost certainly be called "Planchette" instead of "Cursor", but who wants to type that word a million times?
 */
public class BasicCursor extends SceneObject
    implements IEventDispatcher
{
    public function BasicCursor (board :InteractiveObject)
    {
        _ed = new EventDispatcher(this);
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

    override protected function addedToDB (db :ObjectDB) :void
    {
        _board.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
        _sprite.x = _board.mouseX;
        _sprite.y = _board.mouseY;
    }

    protected function mouseMoved (e :MouseEvent) :void
    {
        this.updateLocation(_board.mouseX, _board.mouseY);
    }

    protected function updateLocation (localX :Number, localY :Number) :void
    {
        _sprite.x = localX;
        _sprite.y = localY;
    }

    // from IEventDispatcher
    public function addEventListener (type :String, listener :Function, useCapture :Boolean = false, priority :int = 0, useWeakReference :Boolean = false) :void
    {
        _ed.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    // from IEventDispatcher
    public function dispatchEvent (event :Event) :Boolean
    {
        return _ed.dispatchEvent(event);
    }

    // from IEventDispatcher
    public function hasEventListener (type :String) :Boolean
    {
        return _ed.hasEventListener(type);
    }

    // from IEventDispatcher
    public function removeEventListener (type :String, listener :Function, useCapture :Boolean = false) :void
    {
        _ed.removeEventListener(type, listener, useCapture);
    }

    // from IEventDispatcher
    public function willTrigger (type :String) :Boolean
    {
        return _ed.willTrigger(type);
    }

    protected var _board :InteractiveObject;
    protected var _sprite :Sprite = new Sprite();
    protected var _cursorImage :Bitmap;
    protected var _ed :EventDispatcher;

    protected static const CENTER :Vector2 = new Vector2(26, 25);
}

}
