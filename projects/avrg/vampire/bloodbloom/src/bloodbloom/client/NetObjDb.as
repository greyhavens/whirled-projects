package bloodbloom.client {

import com.whirled.contrib.simplegame.ObjectDB;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;

import flash.display.DisplayObjectContainer;

public class NetObjDb extends ObjectDB
{
    override public function addObject (obj :SimObject,
        displayParent :DisplayObjectContainer = null) :SimObjectRef
    {
        if (!(obj is NetObj)) {
            throw new Error("Only NetObj's can be added to NetObjDb");
        } else {
            return super.addObject(obj, displayParent);
        }
    }

    override public function update (dt :Number) :void
    {
        _modeTime += dt;
        super.update(dt);
    }

    public function get modeTime () :Number
    {
        return _modeTime;
    }

    protected var _modeTime :Number = 0;
}

}
