package com.whirled.contrib.avrg
{
import com.threerings.flash.MathUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.NetConstants;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

/**
 * This class is intended for HUD elements for AVRGs that also use Tim's simplegame framework.
 * The DraggableSceneObject can be dragged around the screen but it won't go outside the paintable
 * area, and if the screen is resized, it will make sure it's visible.
 *
 */
public class DraggableSceneObject extends SceneObject
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

    public function DraggableSceneObject (ctrl :AVRGameControl, persistId :String = null)
    {
        _ctrl = ctrl;
        //Don't store the positions for now
//        _persistId = persistId;

        registerListener(_ctrl.local, AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
        registerListener(_ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, handleEnteredRoom);

        updatePaintable();

        registerListener(_displaySprite, MouseEvent.MOUSE_DOWN, handleMouseDown);
        registerListener(_displaySprite, MouseEvent.MOUSE_UP, handleMouseUp);
    }

    /**
    * Bounds are the bounds of your HUD sprite.
    */
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
//        if (!evt.shiftKey) {
//            return;
//        }

        trace("mouse down");
        if (_offset == null) {
            registerListener(_displaySprite, Event.ENTER_FRAME, handleFrame);
        }

        _mouse = new Point(_displaySprite.parent.mouseX, _displaySprite.parent.mouseY);
        _offset = new Point(_mouse.x - this.x, _mouse.y - this.y);
    }

    protected function handleFrame (evt :Event) :void
    {
        if (_offset == null || _displaySprite.parent == null) {
            // be resilient in unusual circumstances
            removeEventListener(Event.ENTER_FRAME, handleFrame);
            // make sure we're fully reset
            _offset = null;
            return;
        }

        var p :Point = new Point(_displaySprite.parent.mouseX - _offset.x, _displaySprite.parent.mouseY - _offset.y);

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

        if (xTodo && Math.abs(_displaySprite.parent.mouseX - _mouse.x) > DRAG_SAFETY) {
            _xSnap = SNAP_NONE;
            _xFix = p.x;
            xTodo = false;
        }

        if (yTodo && Math.abs(_displaySprite.parent.mouseY - _mouse.y) > DRAG_SAFETY) {
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

//        trace("handleFrame (" + this.x + ", " + this.y + "), bounds=" + _bounds);
    }

    protected function handleMouseUp (evt :MouseEvent) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);

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

        //Make sure we are not outside the paintable area, no matter what.
        this.x = MathUtil.clamp( this.x, Math.abs(_bounds.left), _ctrl.local.getPaintableArea().width - Math.abs(_bounds.right));
        this.y = MathUtil.clamp( this.y, 0 + this.height/2, _ctrl.local.getPaintableArea().height - this.height/2);
    }

    public function centerOnViewableRoom() :void
    {
        //Workaround as roombounds can be bigger than the paintable area
        if( _ctrl.local.getRoomBounds()[0] > _ctrl.local.getPaintableArea().width) {
                this.x = _ctrl.local.getPaintableArea().width/2;
                this.y = _ctrl.local.getPaintableArea().height/2;
        }
        else {
            this.x = _ctrl.local.getRoomBounds()[0]/2;
            this.y = _ctrl.local.getRoomBounds()[1]/2;
        }
    }
    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected var _displaySprite :Sprite = new Sprite();

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

    protected static const log :Log = Log.getLog(DraggableSceneObject);

}
}