package redrover.aitask {

public class AIFunctionTask extends AITask
{
    public function AIFunctionTask (func :Function)
    {
        _func = func;
    }

    override public function clone () :AITask
    {
        return new AIFunctionTask(_func);
    }

    override public function update (dt :Number) :Boolean
    {
        _func();
        return true;
    }

    protected var _func :Function;
}

}
