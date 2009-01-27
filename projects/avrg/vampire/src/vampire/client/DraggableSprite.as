//
// $Id$

package vampire.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.net.NetConstants;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class DraggableSprite extends Sprite
{
    public static const SNAP_NONE :int = 1;
    public static const SNAP_LEFT :int = 2;
    public static const SNAP_TOP :int = 2;  // alias
    public static const SNAP_ROOM_EDGE :int = 3;
    public static const SNAP_BROWSER_EDGE :int = 4;

    public static const PROP_PREFIX :String = NetConstants.makePersistent("draggable_");
    public static const IX_XSNAP :int = 0;
    public static const IX_XFIX :int = 1;
    public static const IX_YSNAP :int = 2;
    public static const IX_YFIX :int = 3;

    public function DraggableSprite (ctrl :AVRGameControl, persistId :String = null)
    {
        _ctrl = ctrl;
        _persistId = persistId;

        _ctrl.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
        _ctrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, handleEnteredRoom);

        updatePaintable();

        this.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
        this.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
    }

    public function init (bounds :Rectangle, xSnap :int, xPos :Number,
                             ySnap :int, yPos :Number, bleed :Number = 0) :void
    {
        _bounds = bounds;
        _bleed = bleed;

        var locData :Dictionary = (_persistId != null) ?
            _ctrl.player.props.get(PROP_PREFIX + _persistId) as Dictionary : null;

        if (locData != null) {
            _xSnap = locData[IX_XSNAP];
            _xFix = locData[IX_XFIX];
            _ySnap = locData[IX_YSNAP];
            _yFix = locData[IX_YFIX];

        } else {
            _xSnap = xSnap;
            _xFix = xPos;
            _ySnap = ySnap;
            _yFix = yPos;
        }

        layout();
    }

    protected function handleMouseDown (evt :MouseEvent) :void
    {
        if (!evt.shiftKey) {
            return;
        }

        if (_offset == null) {
            this.addEventListener(Event.ENTER_FRAME, handleFrame);
        }

        _mouse = new Point(this.parent.mouseX, this.parent.mouseY);
        _offset = new Point(_mouse.x - this.x, _mouse.y - this.y);
    }

    protected function handleFrame (evt :Event) :void
    {
        if (_offset == null || this.parent == null) {
            // be resilient in unusual circumstances
            this.removeEventListener(Event.ENTER_FRAME, handleFrame);
            // make sure we're fully reset
            _offset = null;
            return;
        }

        var p :Point = new Point(this.parent.mouseX - _offset.x, this.parent.mouseY - _offset.y);

        var xTodo :Boolean = false;
        var yTodo :Boolean = false;


        if( _painted == null ) {
            log.error("_painted==null");
            updateRoom ();
        }
        if (_bounds != null && _painted != null) {
            // boundaries are configured: check for snapping
            if (Math.abs(p.x + _bounds.left - _paintable.left) < SNAP_MARGIN) {
                _xSnap = SNAP_LEFT;

            } else if (Math.abs(p.x + _bleed + _bounds.left - _painted.right) < SNAP_MARGIN) {
                _xSnap = SNAP_ROOM_EDGE;

            } else if (Math.abs(p.x + _bounds.right - _paintable.right) < SNAP_MARGIN) {
                _xSnap = SNAP_BROWSER_EDGE;

            } else {
                xTodo = true;
            }

            if (Math.abs(p.y + _bounds.top - _paintable.top) < SNAP_MARGIN) {
                _ySnap = SNAP_TOP;

            } else if (Math.abs(p.y + _bounds.bottom - _paintable.bottom) < SNAP_MARGIN) {
                _ySnap = SNAP_BROWSER_EDGE;

            } else {
                yTodo = true;
            }
        }

        if (xTodo && Math.abs(this.parent.mouseX - _mouse.x) > DRAG_SAFETY) {
            _xSnap = SNAP_NONE;
            _xFix = p.x;
            xTodo = false;
        }

        if (yTodo && Math.abs(this.parent.mouseY - _mouse.y) > DRAG_SAFETY) {
            _ySnap = SNAP_NONE;
            _yFix = p.y;
            yTodo = false;
        }

        if ((xTodo || yTodo) && _persistId != null) {
            var locData :Dictionary = new Dictionary();
            locData[IX_XSNAP] = _xSnap;
            locData[IX_XFIX] = _xFix;
            locData[IX_YSNAP] = _ySnap;
            locData[IX_YFIX] = _yFix;

            _ctrl.player.props.set(PROP_PREFIX + _persistId, locData);
        }

        layout();
    }

    protected function handleMouseUp (evt :MouseEvent) :void
    {
        this.removeEventListener(Event.ENTER_FRAME, handleFrame);

        _offset = null;
    }

    protected function handleSizeChanged (evt :AVRGameControlEvent) :void
    {
        updatePaintable();
        updateRoom();

        layout();
    }

    protected function handleEnteredRoom (evt :AVRGameControlEvent) :void
    {
        updateRoom();

        layout();
    }

    protected function updatePaintable () :void
    {
        var paintable :Rectangle = _ctrl.local.getPaintableArea(true);
        if (paintable != null) {
            _paintable = paintable;
        } else {
            log.warning("getPaintableArea(true) returned null");

            if (_paintable == null) {
                _paintable = new Rectangle(0, 0, 700, 500);
            }
        }

    }

    protected function updateRoom () :void
    {
        var painted :Rectangle = _ctrl.local.getPaintableArea(false);
        if (painted != null) {
            _painted = painted;
        } else {
            log.warning("getPaintableArea(true) returned null");

            if (_painted == null) {
                _painted = new Rectangle(0, 0, 700, 500);
            }
        }
    }

    protected function layout () :void
    {
        if (_bounds == null || _paintable == null || _painted == null) {
            // not yet initialized
            return;
        }

        switch(_xSnap) {
        case SNAP_NONE:
            this.x = _xFix;
            break;
        case SNAP_LEFT:
            this.x = _paintable.left - _bounds.left;
            break;
        case SNAP_ROOM_EDGE:
            this.x = Math.max(0, Math.min(_paintable.right - _bounds.right,
                                          _painted.right - _bounds.left - _bleed));
            break;
        case SNAP_BROWSER_EDGE:
            this.x = Math.max(0, _paintable.right - _bounds.right);
            break;
        }

        switch(_ySnap) {
        case SNAP_NONE:
            this.y = _yFix;
            break;
        case SNAP_TOP:
            this.y = _paintable.top - _bounds.top;
            break;
        case SNAP_ROOM_EDGE:
            this.y = Math.max(0, Math.min(_paintable.bottom - _bounds.bottom,
                                          _painted.bottom - _bounds.top));
            break;
        case SNAP_BROWSER_EDGE:
            this.y = Math.max(0, _paintable.bottom - _bounds.bottom);
            break;
        }
    }

    protected var _ctrl :AVRGameControl;

    protected var _mode :String;

    protected var _persistId :String;

    protected var _bounds :Rectangle;

    protected var _xSnap :int;
    protected var _ySnap :int;

    protected var _xFix :Number;
    protected var _yFix :Number;
    protected var _bleed :Number;

    protected var _mouse :Point;
    protected var _offset :Point;

    protected var _paintable :Rectangle;
    protected var _painted :Rectangle;

    protected static const SNAP_MARGIN :int = 20;
    protected static const DRAG_SAFETY :int = 0;

    protected static const log :Log = Log.getLog(DraggableSprite);
}
}
