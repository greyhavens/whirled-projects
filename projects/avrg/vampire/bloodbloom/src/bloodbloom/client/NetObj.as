package bloodbloom.client {

import com.whirled.contrib.simplegame.SimObject;

public class NetObj extends SimObject
{
    public function get liveTime () :Number
    {
        return _liveTime;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        _liveTime += dt;
    }

    protected var _liveTime :Number = 0; // how long has this object been alive
}

}
