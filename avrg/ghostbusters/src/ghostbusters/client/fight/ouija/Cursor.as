package ghostbusters.client.fight.ouija {

import com.threerings.flash.Vector2;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.BitmapData
import flash.display.Bitmap;
import flash.display.InteractiveObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.filters.GlowFilter;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

/**
 * This should almost certainly be called "Planchette" instead of "Cursor", but who wants to type that word a million times?
 */
public class Cursor extends BasicCursor
    implements IEventDispatcher
{
    public function Cursor (board :InteractiveObject)
    {
        super(board);

        // create a glow for the image
        _glowObject = new SimpleSceneObject(this.createGlowBitmap(_cursorImage));
        _glowObject.alpha = 0;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();

        this.db.addObject(_glowObject, _sprite);
    }

    override protected function removedFromDB () :void
    {
        super.removedFromDB();

        _glowObject.destroySelf();
    }

    override protected function updateLocation (localX :Number, localY :Number) :void
    {
        super.updateLocation(localX, localY);

        // do we need to reset the selection timer?
        var newLoc :Vector2 = new Vector2(localX, localY);
        var delta :Vector2 = new Vector2(localX, localY);
        delta.subtractLocal(_lastSettledLocation);

        if (delta.lengthSquared > ALLOWED_MOVE_DISTANCE) {

            this.removeNamedTasks("SelectionTimer");
            _glowObject.removeAllTasks();
            _glowObject.alpha = 0;

            if (_selectionTargetIndex >= 0 &&
                 Board.pointIntersectsSelection(newLoc, SELECTION_EPSILON, _selectionTargetIndex)) {

                this.addNamedTask("SelectionTimer", new SerialTask(
                    new TimedTask(SELECTION_TIMER_DURATION),
                    new FunctionTask(selectionTimerExpired)));

                _glowObject.addTask(new AlphaTask(1, SELECTION_TIMER_DURATION));
            }

            _lastSettledLocation = delta;
        }
    }

    protected function selectionTimerExpired () :void
    {
        this.dispatchEvent(new BoardSelectionEvent(_selectionTargetIndex));
    }

    public function set glowOnSelection (val :Boolean) :void
    {
        _glowOnSelection = val;
    }

    public function set selectionTargetIndex (val :int) :void
    {
        _selectionTargetIndex = val;
    }

    protected function createGlowBitmap (srcBitmap :Bitmap) :Bitmap
    {
        // add a glow around the image
        var glowData :BitmapData = new BitmapData(
            srcBitmap.width + (GLOW_BUFFER * 2),
            srcBitmap.height + (GLOW_BUFFER * 2),
            true,
            0x00000000);

        var glowFilter :GlowFilter = new GlowFilter();
        glowFilter.color = GLOW_COLOR;
        glowFilter.alpha = 0.4;
        glowFilter.strength = 8;
        glowFilter.knockout = true;

        glowData.applyFilter(
            srcBitmap.bitmapData,
            new Rectangle(0, 0, srcBitmap.width, srcBitmap.height),
            new Point(GLOW_BUFFER, GLOW_BUFFER),
            glowFilter);

        var glowBitmap :Bitmap = new Bitmap(glowData);
        glowBitmap.x = srcBitmap.x - GLOW_BUFFER;
        glowBitmap.y = srcBitmap.y - GLOW_BUFFER;

        return glowBitmap;
    }

    protected var _glowObject :SceneObject;

    protected var _lastSettledLocation :Vector2 = new Vector2();
    protected var _currentSelectionIndex :int = -1;

    protected var _selectionTargetIndex :int = -1;
    protected var _glowOnSelection :Boolean = true;

    protected static const CENTER :Vector2 = new Vector2(26, 25);

    protected static const ALLOWED_MOVE_DISTANCE :int = 2; // distance that the cursor can move without resetting selection timer
    protected static const SELECTION_EPSILON :int = 6; // allowed distance from center of selection
    protected static const SELECTION_TIMER_DURATION :Number = 0.25;

    protected static const GLOW_BUFFER :int = 7;
    protected static const GLOW_COLOR :uint = 0x5BFFFF;
}

}
