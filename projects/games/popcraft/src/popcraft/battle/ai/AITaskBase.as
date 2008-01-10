package popcraft.battle.ai {

import com.threerings.util.Assert;

import com.whirled.contrib.core.*;

import popcraft.battle.CreatureUnit;

public class AITaskBase
    implements AITask
{
    public function AITaskBase ()
    {
    }

    /** Subclasses should implement this. */
    public function get name () :String
    {
        return (null == _parentTask ? "[root]" : "[unnamed task]");
    }

    /** Subclasses should implement this. */
    public function clone () :ObjectTask
    {
        Assert.fail("This task does not implement clone()");
        return null;
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return _subtasks.receiveMessage(msg);
    }

    public function update (dt :Number, obj :AppObject) :Boolean
    {
        return _subtasks.update(dt, obj);
    }

    public function addSubtask (task :AITask) :void
    {
        task.parentTask = this;
        _subtasks.addTask(task);
    }

    public function clearSubtasks () :void
    {
        _subtasks.removeAllTasks();
    }

    public function hasSubtaskNamed (name :String) :Boolean
    {
        return (null != _subtasks.getSubtaskNamed(name));
    }

    public function hasSubtasksNamed (names :Array, index :uint = 0) :Boolean
    {
        if (names.length == 0) {
            return false;
        }

        var subtask :AITask = _subtasks.getSubtaskNamed(names[index]);
        if (null == subtask) {
            return false;
        } else if (index == names.length - 1) {
            return true;
        } else {
            return subtask.hasSubtasksNamed(names, index + 1);
        }
    }

    public function getStateString (depth :uint = 0) :String
    {
        var stateString :String = "";
        for (var i :int = 0; i < depth; ++i) {
            stateString += "- ";
        }

        stateString += this.name;

        var subtaskArray :Array = _subtasks.tasks;
        for each (var task :AITask in subtaskArray) {
            stateString += "\n";
            stateString += task.getStateString(depth + 1);
        }

        return stateString;
    }

    public function get parentTask () :AITask
    {
        return _parentTask;
    }

    public function set parentTask (parentTask :AITask) :void
    {
        _parentTask = parentTask;
    }

    protected var _parentTask :AITask;
    protected var _subtasks :SubtaskContainer = new SubtaskContainer();
}

}

import popcraft.battle.ai.AITask;
import com.whirled.contrib.core.tasks.ParallelTask;
import com.whirled.contrib.core.ObjectMessage;

class SubtaskContainer extends ParallelTask
{
    public function get tasks () :Array
    {
        return _tasks;
    }

    public function getSubtaskNamed (name :String) :AITask
    {
        for each (var task :AITask in _tasks) {
            if (null != task && task.name == name) {
                return task;
            }
        }

        return null;
    }
}
