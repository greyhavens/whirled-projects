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
        return "[unnamed task]";
    }

    /** Subclasses should implement this. */
    public function aiUpdate (dt :Number, unit :CreatureUnit) :Boolean
    {
        return true;
    }

    /** Subclasses should implement this. */
    public function aiReceiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    /** Subclasses should implement this. */
    public function clone () :ObjectTask
    {
        return null;
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        _subtasks.receiveMessage(msg);
        return this.aiReceiveMessage(msg);
    }

    public function update (dt :Number, obj :AppObject) :Boolean
    {
        _subtasks.update(dt, obj);
        return this.aiUpdate(dt, (obj as CreatureUnit));
    }

    public function addSubtask (task :AITask) :void
    {
        _subtasks.addTask(task);
    }

    public function clearSubtasks () :void
    {
        _subtasks.removeAllTasks();
    }

    public function setSubtask (task :AITask) :void
    {
        this.clearSubtasks();
        this.addSubtask(task);
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
            if (task.name == name) {
                return task;
            }
        }

        return null;
    }
}
