package redrover.game.robot {

import com.whirled.contrib.simplegame.SimObject;

import redrover.aitask.AITask;

public class Robot extends SimObject
{
    public function Robot (ai :AITask)
    {
        _ai = ai;
    }

    override protected function update (dt :Number) :void
    {
        _ai.update(dt);
    }

    protected var _ai :AITask;
}

}
