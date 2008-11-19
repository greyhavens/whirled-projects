package redrover.aitask {

public class AIDelayUntilTask extends AITask
{
    public function AIDelayUntilTask (name :String, pred :Function)
    {
        _name = name;
        _pred = pred;
    }

    override public function update (dt :Number) :int
    {
        return (_pred() ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }

    override public function get name () :String
    {
        return _name;
    }

    override public function clone () :AITask
    {
        return new AIDelayUntilTask(_name, _pred);
    }

    protected var _name :String;
    protected var _pred :Function;
}

}
