package popcraft.battle.ai {

import com.threerings.util.Assert;
import com.whirled.contrib.core.*;

public class AIStateTree
    implements AIState
{
    public function AIStateTree ()
    {
    }

    /** Subclasses should implement this. */
    public function get name () :String
    {
        return (null == _parentState ? "[root]" : "[unnamed state]");
    }

    /** Subclasses should implement this. */
    public function clone () :ObjectTask
    {
        Assert.fail("This AIState does not implement clone()");
        return null;
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return _substates.receiveMessage(msg);
    }

    public function update (dt :Number, obj :AppObject) :Boolean
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

    public function get parentState () :AIStateTree
    {
        return _parentState;
    }

    public function set parentState (state :AIStateTree) :void
    {
        _parentState = state;
    }
    
    protected function get subtasksComplete () :Boolean
    {
        return (_substates.tasks.length == 0);
    }

    protected var _parentState :AIStateTree;
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
}
