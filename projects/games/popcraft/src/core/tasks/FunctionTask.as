package core.tasks {

import core.ObjectTask;

public class FunctionTask extends ObjectTask
{
    public function FunctionTask (fn :Function)
    {
        _fn = fn;
    }

    override public function update (dt :Number, obj :AppObject) :uint
    {
        _fn(obj);
        return ObjectTask.STATUS_COMPLETE;
    }

    override public function clone () :ObjectTask
    {
        return new FunctionTask(_fn);
    }

    protected var _fn :Function;
}

}
