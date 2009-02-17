package vampire.feeding.client {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.RotationComponent;

public class ConstantRotationTask
    implements ObjectTask
{
    public function ConstantRotationTask (singleRotationTime :Number, ccw :Boolean)
    {
        _singleRotationTime = singleRotationTime;
        _ccw = ccw;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var rc :RotationComponent = obj as RotationComponent;
        if (rc == null) {
            throw new Error("ConstantRotationTask can only be applied to objects that implement " +
                            "RotationComponent");
        }

        var amount :Number = 360 * (dt / _singleRotationTime);
        if (_ccw) {
            amount *= -1;
        }

        rc.rotation = (rc.rotation + amount) % 360;

        return false;
    }

    public function clone () :ObjectTask
    {
        return new ConstantRotationTask(_singleRotationTime, _ccw);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _elapsedTime :Number = 0;
    protected var _singleRotationTime :Number;
    protected var _ccw :Boolean;
}

}
