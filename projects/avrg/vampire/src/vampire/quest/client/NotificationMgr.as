package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

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
        notification.addTask(new SerialTask(
            new TimedTask(2),
            new AlphaTask(0, 1),
            new SelfDestructTask(),
            new FunctionTask(function () :void {
                _notificationPlaying = false;
                playNextNotification();
            })));

        ClientCtx.appMode.addSceneObject(notification, ClientCtx.notificationLayer);
        _notificationPlaying = true;
    }

    protected function playNextNotification () :void
    {
        if (_pendingNotifications.length > 0) {
            playNotificationNow(_pendingNotifications.shift());
        }
    }

    protected var _pendingNotifications :Array = [];
    protected var _notificationPlaying :Boolean;
}

}
