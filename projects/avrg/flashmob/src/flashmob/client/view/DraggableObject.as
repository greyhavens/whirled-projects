package flashmob.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.InteractiveObject;
import flash.events.MouseEvent;

public class DraggableObject extends SceneObject
{
    public function DraggableObject (draggedCallback :Function = null,
        droppedCallback :Function = null)
    {
        _draggedCallback = draggedCallback;
        _droppedCallback = droppedCallback;
    }

    public function set draggable (val :Boolean) :void
    {
        _draggable = val;
        updateDraggability();
    }

    public function get draggable () :Boolean
    {
        return _draggable;
    }

    protected function updateDraggability () :void
    {
        // Don't updateDraggability until we've been added to the db; this.displayObject
        // may not have been set yet
        if (this.db == null) {
            return;
        }

        if (_draggable && !_isDragRegistered) {
            registerListener(this.draggableObject, MouseEvent.MOUSE_DOWN, startDrag);
            _isDragRegistered = true;

        } else if (!_draggable && _isDragRegistered) {
            unregisterListener(this.draggableObject, MouseEvent.MOUSE_DOWN, startDrag);
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
            _dragOffsetX = -this.displayObject.mouseX;
            _dragOffsetY = -this.displayObject.mouseY;
            _dragging = true;

            registerListener(this.draggableObject, MouseEvent.MOUSE_UP, endDrag);
        }
    }

    protected function endDrag (...ignored) :void
    {
        unregisterListener(this.draggableObject, MouseEvent.MOUSE_UP, endDrag);
        updateDraggedLocation();

        if (_droppedCallback != null) {
            _droppedCallback(this.draggableObject.x, this.draggableObject.y);
        }

        _dragging = false;
    }

    protected function updateDraggedLocation () :void
    {
        if (this.draggableObject.parent != null) {
            var newX :Number = this.draggableObject.parent.mouseX + _dragOffsetX;
            var newY :Number = this.draggableObject.parent.mouseY + _dragOffsetY;
            if (newX != this.draggableObject.x || newY != this.draggableObject.y) {
                this.draggableObject.x = newX;
                this.draggableObject.y = newY;

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

    protected function get draggableObject () :InteractiveObject
    {
        return this.displayObject as InteractiveObject;
    }

    protected var _draggable :Boolean = true;
    protected var _isDragRegistered :Boolean;
    protected var _draggedCallback :Function;
    protected var _droppedCallback :Function;

    protected var _dragOffsetX :Number;
    protected var _dragOffsetY :Number;
    protected var _dragging :Boolean;
}

}
