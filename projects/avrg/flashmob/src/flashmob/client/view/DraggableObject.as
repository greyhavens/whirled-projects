package flashmob.client.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.InteractiveObject;

public class DraggableObject extends SceneObject
{
    public function DraggableObject (draggedCallback :Function = null,
        droppedCallback :Function = null)
    {
        _draggedCallback = draggedCallback;
        _droppedCallback = droppedCallback;
    }

    public function set isDraggable (val :Boolean) :void
    {
        _isDraggable = val;
        if (_dragger != null) {
            _dragger.isDraggable = _isDraggable;
        }
    }

    public function get isDraggable () :Boolean
    {
        return _isDraggable;
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _dragger = new Dragger(this.draggableObject, this.displayObject, _draggedCallback,
            _droppedCallback);
        this.db.addObject(_dragger);

        _dragger.isDraggable = _isDraggable;
    }

    override protected function removedFromDB () :void
    {
        super.removedFromDB();
        _dragger.destroySelf();
    }

    protected function get draggableObject () :InteractiveObject
    {
        return this.displayObject as InteractiveObject;
    }

    protected var _draggedCallback :Function;
    protected var _droppedCallback :Function;

    protected var _dragger :Dragger;
    protected var _isDraggable :Boolean;
}

}
