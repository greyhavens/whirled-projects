package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.display.InteractiveObject;

public class DrawingCursor extends Sprite
{
    public function DrawingCursor (board :InteractiveObject, startLoc :Vector2)
    {
        this.graphics.lineStyle(3, 0xFF0000);
        this.graphics.moveTo(startLoc.x, startLoc.y);

        _points.push(startLoc.clone());

        board.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoved, false, 0, true);
    }

    protected function handleMouseMoved (e :MouseEvent) :void
    {
        var loc :Vector2 = new Vector2(e.localX, e.localY);

        // first point?
        if (null == _lastMouseLoc) {
            _lastMouseLoc = loc;
            return;
        }

        // have we moved far enough?
        var delta :Vector2 = Vector2.subtract(loc, _lastMouseLoc);
        if (delta.lengthSquared < MIN_MOVE_DIST_SQUARED) {
            return;
        }

        // generate our new point
       var lastPoint :Vector2 = _points[_points.length - 1];
       var newPoint :Vector2 = Vector2.add(lastPoint, delta);

       // draw and store the new point
       this.graphics.lineTo(newPoint.x, newPoint.y);
       _points.push(Vector2.add(lastPoint, delta));

       _lastMouseLoc = loc;
    }

    protected var _lastMouseLoc :Vector2;
    protected var _points :Array = new Array();

    protected static const MIN_MOVE_DIST :int = 4;
    protected static const MIN_MOVE_DIST_SQUARED :int = MIN_MOVE_DIST * MIN_MOVE_DIST;

}

}
