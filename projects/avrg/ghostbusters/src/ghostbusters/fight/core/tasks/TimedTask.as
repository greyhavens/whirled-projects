package ghostbusters.fight.core.tasks {

import ghostbusters.fight.core.AppObject;
import ghostbusters.fight.core.ObjectTask;

public class TimedTask extends ObjectTask
{
    public function TimedTask (time :Number)
    {
        _time = time;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        _elapsedTime += dt;

        return (_elapsedTime >= _time);
    }

    override public function clone () :ObjectTask
    {
        return new TimedTask(_time);
    }

    protected var _time :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
