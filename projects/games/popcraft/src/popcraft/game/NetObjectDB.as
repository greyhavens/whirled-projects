package popcraft.game {

import com.whirled.contrib.simplegame.*;

public class NetObjectDB extends ObjectDB
{
    override public function update (dt :Number) :void
    {
        _dbTime += dt;
        super.update(dt);
    }

    public function get dbTime () :Number
    {
        return _dbTime;
    }

    protected var _dbTime :Number = 0;
}

}
