package ghostbusters.fight.common {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.MovieClip;
import flash.text.TextField;

import ghostbusters.fight.Microgame;

public class IntroMode extends AppMode
{
    public function IntroMode (gameName :String, text :String)
    {
        _gameName = gameName;
        _text = text;
    }

    override protected function setup () :void
    {
        var movieRoot :MovieClip = SwfResource.getSwfDisplayRoot("intro.screen") as MovieClip;

        this.modeSprite.addChild(movieRoot);

        // fill in the text
        var directions :MovieClip = movieRoot.directions;
        var gameName :MovieClip = movieRoot.gamename;

        (directions.getChildByName("text") as TextField).text = _text;
        (gameName.getChildByName("text") as TextField).text = _gameName;

        this.addObject(new TimerObj(SCREEN_TIME));
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        // dismiss the screen when the timer has expired
        if (!TimerObj.exists) {
            MainLoop.instance.popMode();
        }
    }

    protected var _gameName :String;
    protected var _text :String;

    protected static const SCREEN_TIME :Number = 1;
}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;
import com.whirled.contrib.simplegame.tasks.SelfDestructTask;

class TimerObj extends SimObject
{
    public static const NAME :String = "TimerObj";

    public static function get exists () :Boolean
    {
        return (null != MainLoop.instance.topMode.getObjectNamed(NAME));
    }

    public function TimerObj (duration :Number)
    {
        this.addTask(new SerialTask(
            new TimedTask(duration),
            new SelfDestructTask()));
    }

    override public function get objectName () :String
    {
        return NAME;
    }
}
