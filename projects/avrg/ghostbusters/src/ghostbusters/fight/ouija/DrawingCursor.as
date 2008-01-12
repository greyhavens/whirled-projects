package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.display.InteractiveObject;

public class DrawingCursor extends Sprite
{
    public function DrawingCursor (board :InteractiveObject, startTarget :Vector2, endTarget :Vector2)
    {
        _board = board;
        _startTarget = startTarget;
        _endTarget = endTarget;

        this.graphics.lineStyle(3, 0x0000FF);

        _board.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved, false, 0, true);
    }

    protected function handleMouseMoved (e :MouseEvent) :void
    {
        var delta :Vector2;
        var loc :Vector2 = new Vector2(e.localX, e.localY);

        // can we start drawing yet?
        if (_points.length <= 0) {
            delta = Vector2.subtract(loc, _startTarget);
            if (delta.lengthSquared <= (MAX_TARGET_DIST * MAX_TARGET_DIST)) {
                _points.push(loc);
                this.graphics.moveTo(loc.x, loc.y);
            }

            return;
        }

        // did we hit the end target?
        delta = Vector2.subtract(_endTarget, loc);
        if (delta.lengthSquared <= (MAX_TARGET_DIST * MAX_TARGET_DIST)) {
            _board.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved);
            return;
        }

        var lastLoc :Vector2 = _points[_points.length - 1];

        // have we moved far enough?
        delta = Vector2.subtract(loc, lastLoc);
        if (delta.lengthSquared < (MIN_MOVE_DIST * MIN_MOVE_DIST)) {
            return;
        }

       // draw and store the new point
       this.graphics.lineTo(loc.x, loc.y);
       _points.push(loc);
    }

    protected var _board :InteractiveObject;

    protected var _startTarget :Vector2;
    protected var _endTarget :Vector2;

    protected var _doneDrawing :Boolean;

    protected var _points :Array = new Array();

    protected static const MAX_TARGET_DIST :int = 3;
    protected static const MIN_MOVE_DIST :int = 4;

}

}
