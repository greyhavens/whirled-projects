package ghostbusters.client.fight.common {

import com.whirled.contrib.simplegame.*;

import ghostbusters.client.fight.Microgame;
import ghostbusters.client.fight.MicrogameContext;
import ghostbusters.client.fight.MicrogameResult;

public class MicrogameMode extends AppMode
    implements Microgame
{
    public function MicrogameMode (difficulty :int, context :MicrogameContext)
    {
        _difficulty = difficulty;
        _context = context;
    }

    public function get difficulty () :int
    {
        return _difficulty;
    }

    public function get context () :MicrogameContext
    {
        return _context;
    }

    public function get durationMS () :Number
    {
        return (this.duration * 1000);
    }

    public function get timeRemainingMS () :Number
    {
        return (this.timeRemaining * 1000);
    }

    public function begin () :void
    {
        MainLoop.instance.pushMode(this);
    }

    public function end () :void
    {
        MainLoop.instance.popAllModes();
    }

    protected function get duration () :Number
    {
        throw new Error("duration() is not implemented!");
    }

    protected function get timeRemaining () :Number
    {
        throw new Error("timeRemaining() is not implemented!");
    }

    public function get gameResult () :MicrogameResult
    {
        throw new Error("gameResult() is not implemented!");
    }

    public function get isDone () :Boolean
    {
        throw new Error("isDone() is not implemented!");
    }

    protected var _difficulty :int;
    protected var _context :MicrogameContext;

}

}
