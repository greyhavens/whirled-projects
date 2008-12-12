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

    public function showNotification (player :Player, text :String, offset :Point, type :int,
        soundName :String = null) :void
    {
        var notification :Notification = new Notification(this, player, text, offset, type,
            soundName);
        if (this.canPlayNotification) {
            notification.play();
        } else {
            _queue.push(notification);
        }
    }

    protected function get canPlayNotification () :Boolean
    {
        return _notificationCount == 0;
    }

    override protected function update (dt :Number) :void
    {
        while (_queue.length > 0 && _notificationCount == 0) {
            var notification :Notification = _queue.shift();
            notification.play();
        }
    }

    public function incrementNotificationCount () :void
    {
        _notificationCount++;
    }

    public function decrementNotificationCount () :void
    {
        _notificationCount--;
    }

    protected var _queue :Array = [];
    protected var _notificationCount :int;
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
import redrover.game.view.NotificationMgr;
import com.whirled.contrib.simplegame.SimObjectRef;

class Notification extends SceneObject
{
    public function Notification (mgr :NotificationMgr, player :Player, text :String,
        offset :Point, type :int, soundName :String)
    {
        _mgr = mgr;
        _playerRef = player.ref;
        _offset = offset;
        _type = type;
        _soundName = soundName;

        _sprite = SpriteUtil.createSprite();

        var tf :TextField = UIBits.createText(text, 1.6, 0, TEAM_TEXT_COLORS[player.teamId]);

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
    }

    public function play () :void
    {
        // The player died. Don't bother playing.
        if (_playerRef.isNull) {
            return;
        }

        var player :Player = Player(_playerRef.object);

        // The player's on another board. Don't bother playing.
        if (player.curBoardId != GameContext.localPlayer.curBoardId) {
            return;
        }

        var worldLoc :Point = new Point(player.loc.x, player.loc.y);
        // convert world loc to screen loc
        var teamSprite :Sprite = GameContext.gameMode.getTeamSprite(player.curBoardId);
        var overlay :Sprite = GameContext.gameMode.overlayLayer;
        var screenLoc :Point = overlay.globalToLocal(teamSprite.localToGlobal(worldLoc));
        screenLoc.x += _offset.x;
        screenLoc.y += _offset.y;

        var animParams :Array = ANIM_PARAMS[_type];
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

        if (_soundName != null) {
            GameContext.playGameSound(_soundName);
        }

        addTask(new SerialTask(
            new TimedTask(pauseTime),
            new ParallelTask(
                LocationTask.CreateEaseIn(screenLoc.x, screenLoc.y - moveDist, moveTime),
                After(moveTime - fadeTime, new AlphaTask(0, fadeTime))),
            new SelfDestructTask()));

        GameContext.gameMode.addObject(this, overlay);
    }

    override protected function addedToDB () :void
    {
        _mgr.incrementNotificationCount();
    }

    override protected function removedFromDB () :void
    {
        _mgr.decrementNotificationCount();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _mgr :NotificationMgr;
    protected var _playerRef :SimObjectRef;
    protected var _type :int;
    protected var _offset :Point;
    protected var _soundName :String;
    protected var _sprite :Sprite;

    protected static const MARGIN :Number = 5;

    protected static const MOVE_DIST_IDX :int = 0;
    protected static const PAUSE_TIME_IDX :int = 1;
    protected static const MOVE_TIME_IDX :int = 2;
    protected static const FADE_TIME_IDX :int = 3;

    protected static const ANIM_PARAMS :Array = [
        [ 100, 1, 1, 0.25 ],        // Major
        [ 40, 0.1, 0.4, 0.15 ],     // Minor
    ];

    protected static const TEAM_TEXT_COLORS :Array = [ 0xff6a6a, 0x6ae8ff ];
}
