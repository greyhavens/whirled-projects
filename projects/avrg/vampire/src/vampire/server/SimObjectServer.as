package vampire.server
{
import com.whirled.contrib.simplegame.SimObject;

import flash.utils.clearInterval;

public class SimObjectServer extends SimObject
{
    public function SimObjectServer()
    {
        super();
    }

    protected function addIntervalId (id :uint) :void
    {
        _intervalIds.push(id);
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        for each (var id :uint in _intervalIds) {
            clearInterval(id);
        }
    }

    protected var _intervalIds :Array = [];

}
}