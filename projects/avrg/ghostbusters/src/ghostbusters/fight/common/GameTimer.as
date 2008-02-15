package ghostbusters.fight.common {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;

public class GameTimer extends SimObject
{
    public static const NAME :String = "GameTimer";
    
    public static function install (totalTime :Number, callback :Function) :void
    {
        var timer :GameTimer = new GameTimer(totalTime, callback);
        MainLoop.instance.topMode.addObject(timer);
    }
    
    public static function uninstall () :void
    {
        MainLoop.instance.topMode.destroyObjectNamed(NAME);
    }
    
    public static function get timeRemaining () :Number
    {
        var timer :GameTimer = MainLoop.instance.topMode.getObjectNamed(NAME) as GameTimer;
        return (null != timer ? timer.timeRemaining : 0);
    }
    
    public function GameTimer (totalTime :Number, callback :Function)
    {
        _timeRemaining = { value: totalTime };
        
        this.addTask(new SerialTask(
            new AnimateValueTask(_timeRemaining, 0, totalTime),
            new FunctionTask(callback)));
    }
    
    public function get timeRemaining () :Number
    {
        return _timeRemaining.value;
    }
    
    override public function get objectName () :String
    {
        return NAME;
    }
    
    protected var _timeRemaining :Object;
    
}

}