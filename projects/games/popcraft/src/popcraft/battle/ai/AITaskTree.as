package popcraft.battle.ai {
    
import com.threerings.util.Assert;
import com.whirled.contrib.core.*;

import popcraft.battle.CreatureUnit;

public class AITaskTree extends AITaskBase
{
    public function AITaskTree ()
    {
    }

    override public function receiveMessage (msg :ObjectMessage) :uint
    {
        this.forEachSubtask(function (task :AITask) :uint { return task.receiveMessage(msg); } );
        
        return AITaskStatus.ACTIVE;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        this.forEachSubtask(function (task :AITask) :uint { return task.update(dt, unit); } );
        
        return AITaskStatus.ACTIVE;
    }
    
    protected function forEachSubtask (fn :Function) :void
    {
        _stopProcessingSubtasks = false;
        
        var n :int = _subtasks.length;
        for (var i :int = 0; i < n; ++i) {
            
            // if _stopProcessingSubtasks is true,
            // our _subtasks Array has become invalidated
            // during iteration and we need to stop processing it.
            if (_stopProcessingSubtasks) {
                break;
            }
            
            var task :AITask = _subtasks[i];
            
            // we can have holes in the array
            if (null != task) {
                var status :uint = fn(task);
                
                if (AITaskStatus.COMPLETE == status) {
                    _subtasks[i] = null;
                    _freeIndices.push(i);
                    
                    var result :AITaskResult = task.taskResult;
                    if (null != result) {
                        this.childTaskCompletedWithResult(result);
                    }
                }
            }
        }
    }

    public function addSubtask (task :AITask) :void
    {
        task.parentTask = this;
        
        if (_freeIndices.length == 0) {
            _subtasks.push(task);
        } else {
            var i :int = _freeIndices.pop();
            
            Assert.isTrue(i >= 0 && i < _subtasks.length && _subtasks[i] == null);
            
            _subtasks[i] = task;
        }
    }

    public function clearSubtasks () :void
    {
        _subtasks = new Array();
        _freeIndices = new Array();
        
        _stopProcessingSubtasks = true;
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
    
    /** Subclasses can override this to do something interesting. */
    protected function childTaskCompletedWithResult (result :AITaskResult) :void
    {
    }

    protected var _subtasks :Array = new Array();
    protected var _freeIndices :Array = new Array();
    protected var _stopProcessingSubtasks :Boolean;
}

}
