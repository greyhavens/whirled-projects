package popcraft.battle.ai {

import com.whirled.contrib.core.*;

public class AIStateTree extends AIStateBase
{
    public function AIStateTree ()
    {
    }
    
    public function handleTransition (fromState :AIState, toState :AIState) :void
    {
        _substates.handleTransition(fromState, toState);
    }

    override public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return _substates.receiveMessage(msg);
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        _substates.update(dt, obj);
        return false;
    }

    public function addSubtask (state :AIState) :void
    {
        state.parentState = this;
        _substates.addTask(state);
    }

    public function clearSubtasks () :void
    {
        _substates.removeAllTasks();
    }

    public function hasSubtaskNamed (name :String) :Boolean
    {
        return (null != _substates.getSubstateNamed(name));
    }

    public function getStateString (depth :uint = 0) :String
    {
        var stateString :String = "";
        for (var i :int = 0; i < depth; ++i) {
            stateString += "- ";
        }

        stateString += this.name;

        var subtaskArray :Array = _substates.tasks;
        for each (var substate :AIState in subtaskArray) {
            stateString += "\n";
            
            if (substate is AIStateTree) {
                stateString += (substate as AIStateTree).getStateString(depth + 1);
            } else {
                for (var j :uint = 0; j < depth + 1; ++j) {
                    stateString += "- ";
                }
                
                stateString += substate.name;
            }
        }

        return stateString;
    }
    
    protected function get subtasksComplete () :Boolean
    {
        return (_substates.tasks.length == 0);
    }

    protected var _substates :SubstateContainer = new SubstateContainer();
}

}

import popcraft.battle.ai.AIState;
import com.whirled.contrib.core.tasks.ParallelTask;
import com.whirled.contrib.core.ObjectMessage;

class SubstateContainer extends ParallelTask
{
    public function get tasks () :Array
    {
        return _tasks;
    }

    public function getSubstateNamed (name :String) :AIState
    {
        for each (var state :AIState in _tasks) {
            if (null != state && state.name == name) {
                return state;
            }
        }

        return null;
    }
    
    public function handleTransition (fromState :AIState, toState :AIState) :void
    {
        for (var i :uint = 0; i < _tasks.length; ++i) {
            if (_tasks[i] === fromState) {
                _tasks[i] = toState;
            }
        }
        
        
    }
}
