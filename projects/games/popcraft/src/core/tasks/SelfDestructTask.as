package core.tasks {

import com.threerings.util.Assert;
import core.ObjectTask;
import core.AppObject;

public class SelfDestructTask extends ObjectTask
{
    public function SelfDestructTask ()
    {
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        obj.removeSelf();
        return true;
    }

    override public function clone () :ObjectTask
    {
        return new SelfDestructTask();
    }
}

}
