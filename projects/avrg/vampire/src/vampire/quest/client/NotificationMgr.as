package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.geom.Rectangle;

public class NotificationMgr
{
    public function addNotification (notification :SceneObject) :void
    {
        if (!_notificationPlaying && _pendingNotifications.length == 0) {
            playNotificationNow(notification);
        } else {
            _pendingNotifications.push(notification);
        }
    }

    protected function playNotificationNow (notification :SceneObject) :void
    {
        if (_bg == null) {
            _bg = new NotificationBg();
            ClientCtx.appMode.addSceneObject(_bg, ClientCtx.notificationLayer);
            _bg.visible = false;
        }

        // show the bg
        _bg.removeAllTasks();
        _bg.alpha = 1;
        _bg.visible = true;

        // show the notification over the bg
        var bounds :Rectangle = ClientCtx.getPaintableArea(false);
        notification.x = bounds.x + ((bounds.width - notification.width) * 0.5);
        notification.y = bounds.y + ((bounds.height - notification.height) * 0.5);

        notification.addTask(new SerialTask(
            new TimedTask(2),
            new FunctionTask(maybeFadeBg),
            new AlphaTask(0, 1),
            new SelfDestructTask(),
            new FunctionTask(function () :void {
                _notificationPlaying = false;
                playNextNotification();
            })));

        ClientCtx.appMode.addSceneObject(notification, ClientCtx.notificationLayer);
        _notificationPlaying = true;
    }

    protected function maybeFadeBg () :void
    {
        if (_pendingNotifications.length == 0) {
            _bg.addTask(new SerialTask(
                new AlphaTask(0, 1),
                new VisibleTask(false)));
        }
    }

    protected function playNextNotification () :void
    {
        if (_pendingNotifications.length > 0) {
            playNotificationNow(_pendingNotifications.shift());
        }
    }

    protected var _pendingNotifications :Array = [];
    protected var _notificationPlaying :Boolean;

    protected var _bg :NotificationBg;
}

}

import flash.display.Shape;
import com.whirled.contrib.simplegame.objects.SceneObject;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.geom.Rectangle;
import vampire.quest.client.ClientCtx;

class NotificationBg extends SceneObject
{
    public function NotificationBg ()
    {
        _shape = new Shape();

        var bounds :Rectangle = ClientCtx.getPaintableArea(false);
        var g :Graphics = _shape.graphics;
        g.beginFill(0, 0.8);
        g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
        g.endFill();
    }

    override public function get displayObject () :DisplayObject
    {
        return _shape;
    }

    protected var _shape :Shape;
}
