//
// $Id$

package popcraft.game.battle.ai {

import popcraft.game.battle.CreatureUnit;

public class AIFunctionTask extends AITask
{
    public function AIFunctionTask (f :Function, name :String = "AIFunctionTask")
    {
        _f = f;
        _name = name;
    }

    override public function get name () :String
    {
        return _name;
    }

    override public function clone () :AITask
    {
        return new AIFunctionTask(_f, _name);
    }

    override public function update (dt :Number, obj :CreatureUnit) :AITaskStatus
    {
        if (_f.length == 2) {
            _f(dt, obj);
        } else {
            _f();
        }

        return AITaskStatus.COMPLETE;
    }

    protected var _f :Function;
    protected var _name :String;
}

}
