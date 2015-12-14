package ghostbusters.client.fight.common {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.text.TextField;

import ghostbusters.client.fight.*;

public class WinLoseNotification extends SceneObject
{
    public static const TIMER_NAME :String = "WinLoseNotification";

    public static function create (success :Boolean, sucessStrings :Array, failStrings :Array, parent :DisplayObjectContainer) :void
    {
        var textArray :Array = (success ? sucessStrings : failStrings);
        var text :String = textArray[Rand.nextIntRange(0, textArray.length, Rand.STREAM_COSMETIC)];

        var notification :WinLoseNotification = new WinLoseNotification(success, text);

        // center on game
        notification.x = (MicrogameConstants.GAME_WIDTH * 0.5);
        notification.y = (MicrogameConstants.GAME_HEIGHT * 0.5);

        FightCtx.mainLoop.topMode.addObject(notification, parent);

        // create a timer object
        FightCtx.mainLoop.topMode.addObject(new SimpleTimer(1.5, null, false, TIMER_NAME));

    }

    public static function get isPlaying () :Boolean
    {
        return (null != FightCtx.mainLoop.topMode.getObjectNamed(TIMER_NAME));
    }

    public function WinLoseNotification (success :Boolean, text :String)
    {
        // instantiate the screen
        _movieClip = SwfResource.instantiateMovieClip(FightCtx.rsrcs, "outro.screen", (success ? "outro_win" : "outro_lose"));

        _movieClip.mouseEnabled = false;
        _movieClip.mouseChildren = false;

        var textField :TextField = _movieClip["message"];
        textField.text = text;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movieClip;
    }

    protected var _movieClip :MovieClip;

}

}
