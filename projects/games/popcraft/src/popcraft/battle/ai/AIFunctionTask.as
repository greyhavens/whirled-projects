package popcraft.battle.ai {

import popcraft.battle.CreatureUnit;

public class AIFunctionTask extends AITask
{
    public function AIFunctionTask (f :Function)
    {
        _f = f;
    }

    override public function clone () :AITask
    {
        return new AIFunctionTask(_f);
    }

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        _f(dt, creature);
        return AITaskStatus.COMPLETE;
    }

    protected var _f :Function;
}

}
