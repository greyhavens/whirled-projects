package core.tasks {

import com.threerings.util.Assert;
import core.ObjectTask;
import core.AppObject;
import flash.utils.describeType;

public class FunctionTask extends ObjectTask
{
    public function FunctionTask (fn :Function)
    {
        Assert.isNotNull(fn);
        Assert.isTrue(fn.length == 0 || fn.length == 1);
        _fn = fn;
    }

    override public function update (dt :Number, obj :AppObject) :uint
    {
        if (_fn.length == 0) {
            _fn();
        } else {
            _fn(obj);
        }

        return ObjectTask.STATUS_COMPLETE;
    }

    override public function clone () :ObjectTask
    {
        return new FunctionTask(_fn);
    }

    protected var _fn :Function;
    protected var _acceptsObjParam :Boolean;
}

}
