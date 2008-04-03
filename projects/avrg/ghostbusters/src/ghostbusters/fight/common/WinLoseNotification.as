package ghostbusters.fight.common {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class WinLoseNotification extends SceneObject
{
    public static const TIMER_NAME :String = "WinLoseNotification";

    public static function create (success :Boolean, parent :DisplayObjectContainer) :void
    {
        var notification :WinLoseNotification = new WinLoseNotification(success);

        // center on game
        notification.x = (MicrogameConstants.GAME_WIDTH * 0.5);
        notification.y = (MicrogameConstants.GAME_HEIGHT * 0.5);

        MainLoop.instance.topMode.addObject(notification, parent);

        // create a timer object
        MainLoop.instance.topMode.addObject(new SimpleTimer(1.5, null, false, TIMER_NAME));

    }

    public static function get isPlaying () :Boolean
    {
        return (null != MainLoop.instance.topMode.getObjectNamed(TIMER_NAME));
    }

    public function WinLoseNotification (success :Boolean)
    {
        _success = success;

        var textArray :Array = (success ? WIN_TEXT : LOSE_TEXT);
        var text :String = textArray[Rand.nextIntRange(0, textArray.length, Rand.STREAM_COSMETIC)];

        // instantiate the screen
        _movieClip = Resources.instance.instantiateMovieClip("outro.screen", (success ? "outro_win" : "outro_lose"));

        _movieClip.mouseEnabled = false;
        _movieClip.mouseChildren = false;

        var textField :TextField = _movieClip["message"];
        textField.text = text;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movieClip;
    }

    protected var _success :Boolean;
    protected var _movieClip :MovieClip;

    protected static const WIN_TEXT :Array = [
        "POW!",
        "BIFF!",
        "ZAP!",
        "SMACK!",
    ];

    protected static const LOSE_TEXT :Array = [
        "oof",
        "ouch",
        "argh",
        "agh",
    ];

}

}
