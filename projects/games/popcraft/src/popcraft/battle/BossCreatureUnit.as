package popcraft.battle {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Professor Weardd, PhD in Postmortem Ambulation
 */
public class BossCreatureUnit extends ColossusCreatureUnit
{
    public function BossCreatureUnit (owningPlayerId :uint)
    {
        super(owningPlayerId, Constants.UNIT_TYPE_BOSS);
        _ai = new ColossusAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _ai;
    }
}

}
