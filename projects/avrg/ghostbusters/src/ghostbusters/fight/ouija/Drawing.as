package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
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
        
        _drawing.graphics.lineStyle(3, 0x0000FF);
    }
    
    override protected function addedToDB (db :ObjectDB) :void
    {
        super.addedToDB(db);

        _board.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved, false, 0, true);
    }
    
    override protected function removedFromDB (db :ObjectDB) :void
    {
        _board.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved);
    }

    protected function handleMouseMoved (e :MouseEvent) :void
    {
        var delta :Vector2;
        var loc :Vector2 = new Vector2(e.localX, e.localY);

        // can we start drawing yet?
        if (null == _endTarget) {
            var delta1 :Vector2 = Vector2.subtract(loc, _target1);
            var delta2 :Vector2 = Vector2.subtract(loc, _target2);
            
            if (delta1.lengthSquared <= (MAX_TARGET_DIST * MAX_TARGET_DIST)) {
                _points.push(loc);
                _drawing.graphics.moveTo(loc.x, loc.y);
                _endTarget = _target2;
            } else if (delta2.lengthSquared <= (MAX_TARGET_DIST * MAX_TARGET_DIST)) {
                _points.push(loc);
                _drawing.graphics.moveTo(loc.x, loc.y);
                _endTarget = _target1;
            }

            return;
        }
        
        // can we end the drawing?
        if (!_canEndDrawing) {
            delta = Vector2.subtract(_endTarget, loc);
            _canEndDrawing = (delta.lengthSquared >= (10 * 10));
        }

        if (_canEndDrawing) {
            // did we hit the end target?
            delta = Vector2.subtract(_endTarget, loc);
            if (delta.lengthSquared <= (MAX_TARGET_DIST * MAX_TARGET_DIST)) {
                _board.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved);
                _doneDrawing = true;
                return;
            }
        }

        var lastLoc :Vector2 = _points[_points.length - 1];

        // have we moved far enough?
        delta = Vector2.subtract(loc, lastLoc);
        if (delta.lengthSquared < (MIN_MOVE_DIST * MIN_MOVE_DIST)) {
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
    
    protected static const MAX_TARGET_DIST :int = 3;
    protected static const MIN_MOVE_DIST :int = 1;

}

}
