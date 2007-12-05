package core {

import com.threerings.util.Assert;

public class ObjectTask
{
    public static const STATUS_INCOMPLETE :uint = 0;
    public static const STATUS_COMPLETE :uint = 1;

    /**
     * Updates the IObjectTask.
     * Returns STATUS_COMPLETE if the task has completed, otherwise STATUS_INCOMPLETE.
     */
    public function update (dt :Number, obj :AppObject) :uint
    {
        return STATUS_COMPLETE;
    }

    /** Returns a copy of the ObjectTask */
    public function clone () :ObjectTask
    {
        Assert.fail("ObjectTask.clone() called on a task that doesn't implement it.");
        return null;
    }
}

}
