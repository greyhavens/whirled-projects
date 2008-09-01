package ghostbusters.client.fight.common {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.tasks.*;

public class GameTimer
{
    public static function install (totalTime :Number, callback :Function) :void
    {
        MainLoop.instance.topMode.addObject(new SimpleTimer(totalTime, callback, false, NAME));
    }

    public static function uninstall () :void
    {
        MainLoop.instance.topMode.destroyObjectNamed(NAME);
    }

    public static function get timeRemaining () :Number
    {
        var timer :SimpleTimer = MainLoop.instance.topMode.getObjectNamed(NAME) as SimpleTimer;
        return (null != timer ? timer.timeLeft : 0);
    }

    protected static const NAME :String = "GameTimer";

}

}
