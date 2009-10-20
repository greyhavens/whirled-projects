package equip
{
import com.threerings.flashbang.GameObject;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.geom.Point;

public class MouseFollower extends GameObject
{
    override protected function update (dt:Number) :void
    {
        if (!_followMouse) {
            return;
        }

        if (_stopFollowingCheck != null && _stopFollowingCheck()) {
            _stopFollowing();
            _followMouse = false;
        }

        if (_objectToFollowMouse != null && _objectToFollowMouse.parent != null) {
            centerOnMouse();
        }
    }

    public function followMouse (displayObject :DisplayObject, until :int = 1,
        stopFollowingCallback :Function = null, stopFollowingCheck :Function = null) :void
    {
        _objectToFollowMouse = displayObject;
        _stopFollowingCheck = stopFollowingCheck;
        _stopFollowingCallback = stopFollowingCallback;
        switch (until) {
            case UNTIL_MOUSE_UP:
            followMouseUntilMouseUp(displayObject as InteractiveObject);
            break;
        }
    }

    protected function centerOnMouse () :void
    {
        var global :Point = _objectToFollowMouse.parent.localToGlobal(
            new Point(_objectToFollowMouse.parent.mouseX, _objectToFollowMouse.parent.mouseY));
        var localPoint :Point = _objectToFollowMouse.parent.globalToLocal(global);
        _objectToFollowMouse.x = localPoint.x //- _objectToFollowMouse.width / 2;
        _objectToFollowMouse.y = localPoint.y //- _objectToFollowMouse.height / 2;
    }


    public function followMouseUntilMouseUp (o :InteractiveObject) :void
    {
        _stopFollowing = function (...ignored) :void {
            unregisterListener(o, MouseEvent.MOUSE_UP, _stopFollowing);
            _followMouse = false;
            if (_stopFollowingCallback != null) {
                _stopFollowingCallback();
            }
            _objectToFollowMouse = null;
            _stopFollowingCheck = null;
            _stopFollowing = null;
            _stopFollowingCallback = null;
        };
        registerListener(o, MouseEvent.MOUSE_UP, _stopFollowing);
        _followMouse = true;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected var _followMouse :Boolean = false;
    protected var _objectToFollowMouse :DisplayObject;
    protected var _stopFollowingCheck :Function;
    protected var _stopFollowing :Function;
    protected var _stopFollowingCallback :Function;

    public static const UNTIL_MOUSE_UP :int = 1;
    public static const UNTIL_MOUSE_DOWN :int = 2;
    public static const UNTIL_NOTIFICATION :int = 3;
    public static const UNTIL_FUNCTION_RETURNS_FALSE :int = 4;
    public static const NAME :String = "MouseFollower";
}
}
