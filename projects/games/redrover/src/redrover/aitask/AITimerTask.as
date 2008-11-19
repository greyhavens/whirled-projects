package redrover.aitask {

public class AITimerTask extends AITask
{
    public static const DEFAULT_NAME :String = "Timer";

    public function AITimerTask (time :Number, taskName :String = DEFAULT_NAME)
    {
        _totalTime = time;

        _name = taskName;
    }

    override public function update (dt :Number) :int
    {
        _elapsedTime += dt;

        return (_elapsedTime >= _totalTime ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }

    override public function get name () :String
    {
        return _name;
    }

    override public function clone () :AITask
    {
        return new AITimerTask(_totalTime, _name);
    }

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;

    protected var _name :String;

}

}
