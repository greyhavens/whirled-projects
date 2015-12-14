package vampire.combat.client
{
import com.threerings.flashbang.objects.Dragger;
import com.threerings.flashbang.objects.SceneObjectParent;

import flash.display.InteractiveObject;

public class DraggableSceneObjectParent extends SceneObjectParent
{
    public function get dragger () :Dragger
    {
        return _dragger;
    }

    protected function createDragger () :Dragger
    {
        return new Dragger(this.draggableObject, this.displayObject);
    }

    override protected function addedToDB () :void
    {
        _dragger = createDragger();
        this.db.addObject(_dragger);

        super.addedToDB();
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

    protected var _dragger :Dragger;

}
}
