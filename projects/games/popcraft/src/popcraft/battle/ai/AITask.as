package popcraft.battle.ai {

import com.threerings.util.Assert;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.ParallelTask;

public class AITask extends ObjectTask
{
    public function AITask (name :String)
    {
        _name = name;
    }

    public function get name () :String
    {
        return _name;
    }

    public function receiveMessage (msg :ObjectMessage) :void
    {
        _subtasks.receiveMessage(msg);
    }

    public function addSubtask (task :AITask) :void
    {
        task._parent = this;
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

    public function hasSubtasksNamed (names :Array) :Boolean
    {
        if (names.length <= 0) {
            return false;
        } else {
            return this.hasSubtasksNamedInternal(names, 0);
        }
    }

    protected function hasSubtasksNamedInternal (names :Array, index :uint) :Boolean
    {
        Assert.isTrue(index < names.length);

        var subtask :AITask = _subtasks.getSubtaskNamed(names[index]);
        if (null == subtask) {
            return false;
        } else if (index == names.length - 1) {
            return true;
        } else {
            return subtask.hasSubtasksNamed(names, index + 1);
        }
    }

    public function getStateString () :String
    {
        return this.getStateStringInternal(0);
    }

    protected function getStateStringInternal (depth :uint) :String
    {
        var stateString :String = "";
        for (var i :int = 0; i < depth; ++i) {
            stateString += "- ";
        }

        stateString += this.name;

        var subtaskArray :Array = _subtasks.tasks;
        for each (var task :AITask in subtaskArray) {
            stateString += "\n";
            stateString += task.getStateStringInternal(depth + 1);
        }

    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var subtasksComplete :Boolean = _subtasks.update(dt, obj);
        return subtasksComplete;
    }

    protected var _name :String;
    protected var _parent :AITask;
    protected var _subtasks :AITaskContainer = new ParallelTask();
}

}

import popcraft.battle.ai.AITask;
import com.whirled.contrib.core.tasks.ParallelTask;
import com.whirled.contrib.core.ObjectMessage;

class AITaskContainer extends ParallelTask
{
    public function get tasks () :Array
    {
        return _tasks;
    }

    public function getSubtaskNamed (name :String) :AITask
    {
        for each (task :AITask in _tasks) {
            if (task.name == name) {
                return task;
            }
        }

        return null;
    }

    public function receiveMessage (msg :ObjectMessage) :void
    {
        for each (task :AITask in _tasks) {
            _task.receiveMessage(msg);
        }
    }
}
