package core {

import com.threerings.util.Assert;

public class ObjectTask
{
    /**
     * Updates the IObjectTask.
     * Returns true if the task has completed, otherwise false.
     */
    public function update (dt :Number, obj :AppObject) :Boolean
    {
        return true;
    }

    /** Returns a copy of the ObjectTask */
    public function clone () :ObjectTask
    {
        Assert.fail("ObjectTask.clone() called on a task that doesn't implement it.");
        return null;
    }
}

}
