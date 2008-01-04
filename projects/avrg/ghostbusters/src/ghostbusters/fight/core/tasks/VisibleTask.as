package ghostbusters.fight.core.tasks {

import ghostbusters.fight.core.ObjectTask;
import ghostbusters.fight.core.AppObject;
import flash.display.DisplayObject;

public class VisibleTask extends ObjectTask
{
    public function VisibleTask (visible :Boolean)
    {
        _visible = visible;
    }

    override public function update (dt :Number, obj :AppObject) :uint
    {
        var displayObj :DisplayObject = obj.displayObject;
        Assert.isNotNull(displayObj, "VisibleTask can only be applied to AppObjects with attached display objects.");

        displayObj.visible = _visible;

        return ObjectTask.STATUS_COMPLETE;
    }

    override public function clone () :ObjectTask
    {
        return new VisibleTask(_visible);
    }

    protected var _visible :Boolean;
}

}
