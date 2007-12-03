package core.tasks {

import core.ObjectTask;

public class TimedTask extends ObjectTask
{
    public function TimedTask (time :Number)
    {
        _time = time;
    }

    override public function update (dt :Number, obj :AppObject) :uint
    {
        _elapsedTime += dt;

        return (_elapsedTime >= _time ? ObjectTask.STATUS_COMPLETE : ObjectTask.STATUS_INCOMPLETE);
    }

    override public function clone () :ObjectTask
    {
        return new TimedTask(_time);
    }

    protected var _time :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
