package popcraft.battle.ai {

import popcraft.battle.CreatureUnit;    
    
public class AIDelayState extends AIStateBase
{
    public function AIDelayState (delayTime :Number, nextState :AIState)
    {
        _totalTime = delayTime;
        _nextState = nextState;
    }
    
    override public function get name () :String
    {
        var name :String = "[DelayState]";
        if (null != _nextState) {
            name += "->" + _nextState.name;
        }
        
        return name;
    }
    
    override public function update (dt :Number, unit :CreatureUnit) :AIState
    {
        _elapsedTime += dt;
        
        return (_elapsedTime >= _totalTime ? _nextState : this);
    }
    
    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
    protected var _nextState :AIState;
    
}

}