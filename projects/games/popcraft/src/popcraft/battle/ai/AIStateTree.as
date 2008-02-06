package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.battle.CreatureUnit;

public class AIStateTree extends AIStateBase
{
    public function AIStateTree ()
    {
    }

    override public function receiveMessage (msg :ObjectMessage) :AIState
    {
        this.forEachSubstate(function (state :AIState) :AIState { return state.receiveMessage(msg); } );
        return this;
    }

    override public function update (dt :Number, unit :CreatureUnit) :AIState
    {
        this.forEachSubstate(function (state :AIState) :AIState { return state.update(dt, unit); } );
        return this;
    }
    
    protected function forEachSubstate (fn :Function) :void
    {
        if (_substates.length == 0) {
            return;
        }
        
        var nextSubstates :Array = new Array();
        for each (var state :AIState in _substates) {
            var nextState :AIState = fn(state);
            if (null != nextState) {
                nextSubstates.push(nextState);
            }
        }
        
        _substates = nextSubstates;
    }

    public function addSubstate (state :AIState) :void
    {
        state.parentState = this;
        _substates.push(state);
    }

    public function clearSubstates () :void
    {
        _substates = new Array();
    }

    public function hasSubstate (name :String) :Boolean
    {
        for each (var state :AIState in _substates) {
            if (state.name == name) {
                return true;
            }
        }
        
        return false;
    }

    public function getStateString (depth :uint = 0) :String
    {
        var stateString :String = "";
        for (var i :int = 0; i < depth; ++i) {
            stateString += "-";
        }

        stateString += this.name;

        for each (var substate :AIState in _substates) {
            stateString += "\n";
            
            if (substate is AIStateTree) {
                stateString += (substate as AIStateTree).getStateString(depth + 1);
            } else {
                for (var j :uint = 0; j < depth + 1; ++j) {
                    stateString += "-";
                }
                
                stateString += substate.name;
            }
        }

        return stateString;
    }

    protected var _substates :Array = new Array();
}

}
