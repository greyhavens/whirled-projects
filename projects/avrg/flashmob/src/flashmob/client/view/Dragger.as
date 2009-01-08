package flashmob.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;

public class Dragger extends SceneObject
{
    public function Dragger (draggableObj :InteractiveObject, displayObj :DisplayObject = null,
        draggedCallback :Function = null,
        droppedCallback :Function = null)
    {
        _draggableObj = draggableObj;
        _displayObj = (displayObj != null ? displayObj : draggableObj);
        _draggedCallback = draggedCallback;
        _droppedCallback = droppedCallback;
    }

    public function set isDraggable (val :Boolean) :void
    {
        _isDraggable = val;
        updateDraggability();
    }

    public function get isDraggable () :Boolean
    {
        return _isDraggable;
    }

    protected function updateDraggability () :void
    {
        // Don't updateDraggability until we've been added to the db
        if (this.db == null) {
            return;
        }

        if (_isDraggable && !_isDragRegistered) {
            registerListener(_draggableObj, MouseEvent.MOUSE_DOWN, startDrag);
            _isDragRegistered = true;

        } else if (!_isDraggable && _isDragRegistered) {
            unregisterListener(_draggableObj, MouseEvent.MOUSE_DOWN, startDrag);
            _isDragRegistered = false;
            if (_dragging) {
                endDrag();
            }
        }
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        updateDraggability();
    }

    protected function startDrag (...ignored) :void
    {
        if (!_dragging) {
            _dragOffsetX = -_displayObj.mouseX;
            _dragOffsetY = -_displayObj.mouseY;
            _dragging = true;

            registerListener(_draggableObj, MouseEvent.MOUSE_UP, endDrag);
        }
    }

    protected function endDrag (...ignored) :void
    {
        unregisterListener(_draggableObj, MouseEvent.MOUSE_UP, endDrag);
        updateDraggedLocation();

        if (_droppedCallback != null) {
            _droppedCallback(_draggableObj.x, _draggableObj.y);
        }

        _dragging = false;
    }

    protected function updateDraggedLocation () :void
    {
        if (_draggableObj.parent != null) {
            var newX :Number = _displayObj.parent.mouseX + _dragOffsetX;
            var newY :Number = _displayObj.parent.mouseY + _dragOffsetY;
            if (newX != _displayObj.x || newY != _displayObj.y) {
                _displayObj.x = newX;
                _displayObj.y = newY;

                if (_draggedCallback != null) {
                    _draggedCallback(newX, newY);
                }
            }
        }
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_dragging) {
            updateDraggedLocation();
        }
    }

    protected var _draggableObj :InteractiveObject;
    protected var _displayObj :DisplayObject;

    protected var _isDraggable :Boolean = true;
    protected var _isDragRegistered :Boolean;
    protected var _draggedCallback :Function;
    protected var _droppedCallback :Function;

    protected var _dragOffsetX :Number;
    protected var _dragOffsetY :Number;
    protected var _dragging :Boolean;
}

}
