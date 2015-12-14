package ghostbusters.client.fight.common {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.tasks.*;

import ghostbusters.client.fight.*;

public class GameTimer
{
    public static function install (totalTime :Number, callback :Function) :void
    {
        FightCtx.mainLoop.topMode.addObject(new SimpleTimer(totalTime, callback, false, NAME));
    }

    public static function uninstall () :void
    {
        FightCtx.mainLoop.topMode.destroyObjectNamed(NAME);
    }

    public static function get timeRemaining () :Number
    {
        var timer :SimpleTimer = FightCtx.mainLoop.topMode.getObjectNamed(NAME) as SimpleTimer;
        return (null != timer ? timer.timeLeft : 0);
    }

    protected static const NAME :String = "GameTimer";

}

}
