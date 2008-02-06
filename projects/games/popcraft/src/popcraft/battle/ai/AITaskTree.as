package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.battle.CreatureUnit;

public class AITaskTree extends AITaskBase
{
    public function AITaskTree ()
    {
    }

    override public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        this.forEachSubtask(function (state :AITask) :Boolean { return state.receiveMessage(msg); } );
        return (_subtasks.length == 0);
    }

    override public function update (dt :Number, unit :CreatureUnit) :Boolean
    {
        this.forEachSubtask(function (state :AITask) :Boolean { return state.update(dt, unit); } );
        return (_subtasks.length == 0);
    }
    
    protected function forEachSubtask (fn :Function) :void
    {
        if (_subtasks.length == 0) {
            return;
        }
        
        var nextSubtasks :Array = new Array();
        for each (var state :AITask in _subtasks) {
            var complete :Boolean = fn(state);
            if (!complete) {
                nextSubtasks.push(state);
            }
        }
        
        _subtasks = nextSubtasks;
    }

    public function addSubtask (task :AITask) :void
    {
        task.parentTask = this;
        _subtasks.push(task);
    }

    public function clearSubtasks () :void
    {
        _subtasks = new Array();
    }

    public function getStateString (depth :uint = 0) :String
    {
        var stateString :String = "";
        for (var i :int = 0; i < depth; ++i) {
            stateString += "-";
        }

        stateString += this.name;

        for each (var subtask :AITask in _subtasks) {
            stateString += "\n";
            
            if (subtask is AITaskTree) {
                stateString += (subtask as AITaskTree).getStateString(depth + 1);
            } else {
                for (var j :uint = 0; j < depth + 1; ++j) {
                    stateString += "-";
                }
                
                stateString += subtask.name;
            }
        }

        return stateString;
    }

    protected var _subtasks :Array = new Array();
}

}
