package ghostbusters.fight.common {
    
import com.whirled.contrib.core.*;

import ghostbusters.fight.Microgame;
import ghostbusters.fight.MicrogameResult;
    
public class MicrogameMode extends AppMode
    implements Microgame
{
    public function MicrogameMode (difficulty :int, playerData :Object)
    {
        _difficulty = difficulty;
        _playerData = playerData;
    }
    
    public function get difficulty () :int
    {
        return _difficulty;
    }
    
    public function get playerData () :Object
    {
        return _playerData;
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
    protected var _playerData :Object;

}

}