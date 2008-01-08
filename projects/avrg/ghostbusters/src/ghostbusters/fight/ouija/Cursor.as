package ghostbusters.fight.ouija {
    
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import com.whirled.contrib.core.AppMode;
import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.Vector2;
import com.whirled.contrib.core.tasks.FunctionTask;
import com.whirled.contrib.core.tasks.SerialTask;
import com.whirled.contrib.core.tasks.TimedTask;

/**
 * This should almost certainly be called "Planchette" instead of "Cursor", but who wants to type that word a million times?
 */
public class Cursor extends AppObject
    implements IEventDispatcher
{
    public function Cursor (board :Board)
    {
        _ed = new EventDispatcher(this);
        
        _board = board;
        
        // add the image, aligned by the center of its viewier
        var image :Bitmap = new IMAGE_PLANCHETTE();
        image.x = -CENTER.x;
        image.y = -CENTER.y;
        _sprite.addChild(image);
        
        _sprite.mouseEnabled = false;
        _sprite.mouseChildren = false;
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    override protected function addedToMode (mode :AppMode) :void
    {
        _board.interactiveObject.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
        _sprite.x = _board.displayObject.mouseX;
        _sprite.y = _board.displayObject.mouseY;
    }
    
    protected function mouseMoved (e :MouseEvent) :void
    {
        this.updateLocation(_board.displayObject.mouseX, _board.displayObject.mouseY);
    }
    
    protected function updateLocation (localX :Number, localY :Number) :void
    {
        _sprite.x = localX;
        _sprite.y = localY;
        
        // do we need to reset the selection timer?
        var newLoc :Vector2 = new Vector2(localX, localY);
        var delta :Vector2 = new Vector2(localX, localY);
        delta.subtract(_lastSettledLocation);
        
        if (delta.lengthSquared > ALLOWED_MOVE_DISTANCE) {
            this.removeNamedTasks("SelectionTimer");
            this.addNamedTask("SelectionTimer", new SerialTask(
                new TimedTask(SELECTION_TIMER_DURATION),
                new FunctionTask(selectionTimerExpired)));
                    
            _lastSettledLocation = delta;
        }
    }
    
    protected function selectionTimerExpired () :void
    {
        // determine our selection
        var newSelection :int = Board.getSelectionIndexAt(new Vector2(_sprite.x, _sprite.y), SELECTION_EPSILON);
        if (newSelection != _currentSelectionIndex && newSelection >= 0) {
            _currentSelectionIndex = newSelection;
            _ed.dispatchEvent(new BoardSelectionEvent(_currentSelectionIndex));
            trace("new selection :" + Board.selectionIndexToString(_currentSelectionIndex));
        }
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
    
    protected var _board :Board;
    protected var _sprite :Sprite = new Sprite();
    protected var _ed :EventDispatcher;

    protected var _lastSettledLocation :Vector2 = new Vector2();    
    protected var _currentSelectionIndex :int = -1;
    
    protected static const CENTER :Vector2 = new Vector2(26, 25);
    
    protected static const ALLOWED_MOVE_DISTANCE :int = 2; // distance that the cursor can move without resetting selection timer
    protected static const SELECTION_EPSILON :int = 6; // allowed distance from center of selection
    protected static const SELECTION_TIMER_DURATION :Number = 0.25;
    
    [Embed(source="../../../../rsrc/ouijaplanchette.png")]
    protected static const IMAGE_PLANCHETTE :Class;
}

}
