package ghostbusters.fight.core.tasks {

import com.threerings.util.Assert;
import ghostbusters.fight.core.ObjectTask;
import ghostbusters.fight.core.AppObject;

public class FunctionTask extends ObjectTask
{
    public function FunctionTask (fn :Function)
    {
        Assert.isNotNull(fn);
        Assert.isTrue(fn.length == 0 || fn.length == 1);
        _fn = fn;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        if (_fn.length == 0) {
            _fn();
        } else {
            _fn(obj);
        }

        return true;
    }

    override public function clone () :ObjectTask
    {
        return new FunctionTask(_fn);
    }

    protected var _fn :Function;
}

}
