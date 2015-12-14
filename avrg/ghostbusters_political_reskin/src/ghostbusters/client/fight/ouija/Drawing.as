package ghostbusters.client.fight.ouija {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

public class Drawing extends SceneObject
{
    public function Drawing (board :InteractiveObject, startTarget :Vector2, endTarget :Vector2)
    {
        _board = board;
        _target1 = startTarget;
        _target2 = endTarget;

        // if the two target points are identical, we can't
        // end the drawing until the user gets far enough away
        // from his starting position
        _canEndDrawing = !(_target1.equals(_target2));

        _drawing.graphics.lineStyle(Constants.PICTO_LINEWIDTH, 0x0000FF);
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();

        _board.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved, false, 0, true);
    }

    override protected function removedFromDB () :void
    {
        _board.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved);
    }

    protected function handleMouseMoved (e :MouseEvent) :void
    {
        var delta :Vector2;
        var loc :Vector2 = new Vector2(e.localX, e.localY);

        // can we start drawing yet?
        if (null == _endTarget) {
            var delta1 :Vector2 = loc.subtract(_target1);
//            var delta2 :Vector2 = loc.subtract(_target2);

            if (delta1.lengthSquared <= (Constants.PICTO_TARGETRADIUS * Constants.PICTO_TARGETRADIUS)) {
                _points.push(loc);
                _drawing.graphics.moveTo(loc.x, loc.y);
                _endTarget = _target2;
                dispatchEvent( new Event(STARTED_DRAWING));
            } 
//            else if (delta2.lengthSquared <= (Constants.PICTO_TARGETRADIUS * Constants.PICTO_TARGETRADIUS)) {
//                _points.push(loc);
//                _drawing.graphics.moveTo(loc.x, loc.y);
//                _endTarget = _target1;
//                dispatchEvent( new Event(STARTED_DRAWING));
//            }

            return;
        }

        // can we end the drawing?
        if (!_canEndDrawing) {
            delta = _endTarget.subtract(loc);
            _canEndDrawing = (delta.lengthSquared >= (10 * 10));
        }

        if (_canEndDrawing) {
            // did we hit the end target?
            delta = _endTarget.subtract(loc);
            if (delta.lengthSquared <= (Constants.PICTO_TARGETRADIUS * Constants.PICTO_TARGETRADIUS)) {
                _board.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved);
                _doneDrawing = true;
                return;
            }
        }

        var lastLoc :Vector2 = _points[_points.length - 1];

        // have we moved far enough?
        delta = loc.subtract(lastLoc);
        if (delta.lengthSquared < (Constants.PICTO_MINLINELENGTH * Constants.PICTO_MINLINELENGTH)) {
            return;
        }

       // draw and store the new point
       _drawing.graphics.lineTo(loc.x, loc.y);
       _points.push(loc);
    }

    override public function get displayObject () :DisplayObject
    {
        return _drawing;
    }

    public function get isDone () :Boolean
    {
        return _doneDrawing;
    }

    public function get points () :Array
    {
        return _points;
    }

    protected var _canEndDrawing :Boolean;

    protected var _board :InteractiveObject;
    protected var _drawing :Shape = new Shape();

    protected var _target1 :Vector2;
    protected var _target2 :Vector2;
    protected var _endTarget :Vector2;

    protected var _doneDrawing :Boolean;

    protected var _points :Array = new Array();
    
    public static const STARTED_DRAWING :String = "Started Drawing";

}

}
