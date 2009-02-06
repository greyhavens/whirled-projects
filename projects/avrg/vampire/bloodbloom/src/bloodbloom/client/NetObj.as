package bloodbloom.client {

import com.whirled.contrib.simplegame.SimObject;

public class NetObj extends SimObject
{
    override protected function update (dt :Number) :void
    {
        super.update(dt);
        _objTime += dt;
    }

    protected var _objTime :Number = 0;
}

}
