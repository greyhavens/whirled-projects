package redrover.game.view {

import com.whirled.contrib.simplegame.SimObject;

import flash.geom.Point;

import redrover.*;
import redrover.game.*;

public class NotificationMgr extends SimObject
{
    // Notification types
    public static const MAJOR :int = 0;
    public static const MINOR :int = 1;

    public function showNotification (teamId :int, text :String, worldLoc :Point, type :int) :void
    {
        var notification :Notification = new Notification(teamId, text, worldLoc, type);
        if (!this.isNotificationPlaying) {
            playNotification(notification);
        } else {
            _queue.push(notification);
        }
    }

    protected function playNotification (notification :Notification) :void
    {
        this.db.addObject(notification, GameContext.gameMode.overlayLayer);
    }

    override protected function update (dt :Number) :void
    {
        if (_queue.length > 0 && !this.isNotificationPlaying) {
            playNotification(Notification(_queue.shift()));
        }
    }

    protected function get isNotificationPlaying () :Boolean
    {
        return this.db.getObjectRefsInGroup(Notification.GROUP_NAME).length > 0;
    }

    protected var _queue :Array = [];
}

}

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import redrover.*;
import redrover.game.*;
import redrover.util.SpriteUtil;
import redrover.ui.UIBits;

class Notification extends SceneObject
{
    public static const GROUP_NAME :String = "Notification";

    public function Notification (teamId :int, text :String, worldLoc :Point, type :int)
    {
        _sprite = SpriteUtil.createSprite();

        var tf :TextField = UIBits.createText(text, 1.6, 0, TEAM_TEXT_COLORS[teamId]);

        var shape :Shape = new Shape();
        shape.graphics.beginFill(0);
        shape.graphics.drawRoundRect(0, 0, tf.width + 10, tf.height + 6, 60, 40);
        shape.graphics.endFill();

        shape.x = -shape.width * 0.5;
        shape.y = -shape.height * 0.5;
        _sprite.addChild(shape);

        tf.x = -tf.width * 0.5;
        tf.y = -tf.height * 0.5;
        _sprite.addChild(tf);

        // convert world loc to screen loc
        var teamSprite :Sprite = GameContext.gameMode.getTeamSprite(teamId);
        var overlay :Sprite = GameContext.gameMode.overlayLayer;
        var screenLoc :Point = overlay.globalToLocal(teamSprite.localToGlobal(worldLoc));

        var animParams :Array = ANIM_PARAMS[type];
        var moveDist :Number = animParams[MOVE_DIST_IDX];
        var pauseTime :Number = animParams[PAUSE_TIME_IDX];
        var moveTime :Number = animParams[MOVE_TIME_IDX];
        var fadeTime :Number = animParams[FADE_TIME_IDX];

        // clamp
        screenLoc.x = Math.max(MARGIN + (_sprite.width * 0.5), screenLoc.x);
        screenLoc.x = Math.min(Constants.SCREEN_SIZE.x - MARGIN - (_sprite.width * 0.5),
            screenLoc.x);
        screenLoc.y = Math.max(moveDist + MARGIN + (_sprite.height * 0.5), screenLoc.y);
        screenLoc.y = Math.min(Constants.SCREEN_SIZE.y - MARGIN - (_sprite.height * 0.5),
            screenLoc.y);

        _sprite.x = screenLoc.x;
        _sprite.y = screenLoc.y;

        addTask(new SerialTask(
            new TimedTask(pauseTime),
            new ParallelTask(
                LocationTask.CreateEaseIn(screenLoc.x, screenLoc.y - moveDist, moveTime),
                After(moveTime - fadeTime, new AlphaTask(0, fadeTime))),
            new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        if (groupNum == 0) {
            return GROUP_NAME;
        } else {
            return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _sprite :Sprite;

    protected static const MARGIN :Number = 5;

    protected static const MOVE_DIST_IDX :int = 0;
    protected static const PAUSE_TIME_IDX :int = 1;
    protected static const MOVE_TIME_IDX :int = 2;
    protected static const FADE_TIME_IDX :int = 3;

    protected static const ANIM_PARAMS :Array = [
        [ 140, 1, 1, 0.25 ],        // Major
        [ 70, 0.5, 0.5, 0.15 ],     // Minor
    ];

    protected static const TEAM_TEXT_COLORS :Array = [ 0xff6a6a, 0x6ae8ff ];
}
