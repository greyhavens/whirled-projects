package popcraft.battle.ai {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.*;

import popcraft.battle.CreatureUnit;

public class AITaskTree
    implements AITask
{
    public function AITaskTree ()
    {
    }

    public function get name () :String
    {
        return "[unnamed task]";
    }

    public function update (dt :Number, unit :CreatureUnit) :uint
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
                var status :uint = task.update(dt, unit);

                if (AITaskStatus.COMPLETE == status) {
                    _subtasks[i] = null;
                    _freeIndices.push(i);

                    this.subtaskCompleted(task);
                }
            }
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
    }

    public function removeSubtaskNamed (name :String, removeAll :Boolean = true) :void
    {
        var n :int = _subtasks.length;
        for (var i :int = 0; i < n; ++i) {

            var task :AITask = _subtasks[i];

            if (null != task && task.name == name) {
                _subtasks[i] = null;
                _freeIndices.push(i);

                if (!removeAll) {
                    break;
                }
            }
        }
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
    protected function subtaskCompleted (task :AITask) :void
    {
    }

    protected var _subtasks :Array = new Array();
    protected var _freeIndices :Array = new Array();
    protected var _stopProcessingSubtasks :Boolean;
}

}
