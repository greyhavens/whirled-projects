package redrover.aitask {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.*;

public class AITaskTree extends AITask
{
    public static const MSG_SUBTASKCOMPLETED :String = "SubtaskCompleted";

    override public function update (dt :Number) :int
    {
        _stopProcessingSubtasks = false;

        var i :int = 0;
        for each (var task :AITask in _subtasks) {
            // we can have holes in the array
            if (null != task) {
                var status :int = task.update(dt);

                if (!_stopProcessingSubtasks && AITaskStatus.COMPLETE == status) {
                    _subtasks[i] = null;
                    _freeIndices.push(i);
                    subtaskCompleted(task);
                }

                // if _stopProcessingSubtasks is true,
                // our _subtasks Array has become invalidated
                // during iteration and we need to stop processing it.
                if (_stopProcessingSubtasks) {
                    break;
                }
            }

            ++i;
        }

        return AITaskStatus.ACTIVE;
    }

    public function addSubtask (task :AITask) :void
    {
        if (_freeIndices.length == 0) {
            _subtasks.push(task);
        } else {
            var i :int = _freeIndices.pop();

            Assert.isTrue(i >= 0 && i < _subtasks.length && _subtasks[i] == null);

            _subtasks[i] = task;
        }

        task._parent = this;
    }

    public function removeSubtaskNamed (name :String, removeAll :Boolean = true) :void
    {
        var i :int = 0;
        for each (var task :AITask in _subtasks) {
            if (null != task && task.name == name) {
                _subtasks[i] = null;
                _freeIndices.push(i);

                task._parent = null;

                if (!removeAll) {
                    break;
                }
            }

            ++i;
        }
    }

    public function hasSubtaskNamed (name :String) :Boolean
    {
        for each (var task :AITask in _subtasks) {
            if (null != task && task.name == name) {
                return true;
            }
        }

        return false;
    }

    public function clearSubtasks () :void
    {
        if (this.hasSubtasks) {
            _subtasks = [];
            _freeIndices = [];

            // if an update() is taking place on this AITaskTree when clearSubtasks() is called,
            // it should stop updating its subtasks immediately.
            _stopProcessingSubtasks = true;
        }
    }

    protected function get hasSubtasks () :Boolean
    {
        return (_subtasks.length - _freeIndices.length) > 0;
    }

    public function getStateString (depth :int = 0) :String
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
                for (var j :int = 0; j < depth + 1; ++j) {
                    stateString += "-";
                }

                stateString += subtask.name;
            }
        }

        return stateString;
    }

    /**
     * Subtasks use this function to communicate with their parent tasks.
     * Subclasses can override this to do something interesting.
     */
    protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
    }

    internal function receiveSubtaskMessageInternal (subtask :AITask, messageName :String, data :Object) :void
    {
        receiveSubtaskMessage(subtask, messageName, data);
    }

    protected function subtaskCompleted (subtask :AITask) :void
    {
        receiveSubtaskMessage(subtask, MSG_SUBTASKCOMPLETED, null);
    }

    protected var _subtasks :Array = new Array();
    protected var _freeIndices :Array = new Array();
    protected var _stopProcessingSubtasks :Boolean;
}

}
