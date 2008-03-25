package ghostbusters.fight.common {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
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
        notification.x = (MicrogameConstants.GAME_WIDTH / 2) - (notification.width / 2);
        notification.y = (MicrogameConstants.GAME_HEIGHT / 2) - (notification.height / 2);

        MainLoop.instance.topMode.addObject(notification, parent);

        // create a timer object
        MainLoop.instance.topMode.addObject(new WinLoseTimer(TIMER_NAME, 1.5));

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

        var label :TextField = new TextField();
        label.text = text;
        label.textColor = (success ? 0xFFFFFF : 0xFF0000);
        label.autoSize = TextFieldAutoSize.LEFT;
        label.scaleX = 4;
        label.scaleY = 4;

        _sprite = new Sprite();
        _sprite.graphics.beginFill(success ? 0x000000 : 0xFFFF00);
        _sprite.graphics.drawRect(0, 0, MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT);
        _sprite.graphics.endFill();

        // center the label on the rect
        label.x = (_sprite.width / 2) - (label.width / 2);
        label.y = (_sprite.height / 2) - (label.height / 2);

        _sprite.addChild(label);

        _sprite.mouseEnabled = false;
        _sprite.mouseChildren = false;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _success :Boolean;
    protected var _sprite :Sprite;

    protected static const WIN_TEXT :Array = [
        "*POW*!",
        "*BIFF*!",
        "*ZAP*!",
        "*SMACK*!",
    ];

    protected static const LOSE_TEXT :Array = [
        "oof",
        "ouch",
        "argh",
        "agh",
    ];

}

}

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

class WinLoseTimer extends SimObject
{
    public function WinLoseTimer (name :String, time :Number)
    {
        _name = name;

        this.addTask(After(time, new SelfDestructTask()));
    }

    override public function get objectName () :String { return _name; }

    protected var _name :String;
}