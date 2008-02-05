package popcraft.battle.ai {

import com.threerings.util.Assert;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;

public class AITaskQueue extends TaskContainer
    implements AITask
{
    public function AITaskQueue (repeating :Boolean)
    {
        super(repeating ? TaskContainer.TYPE_REPEATING : TaskContainer.TYPE_SERIAL);
        _repeating = repeating;
    }

    override public function clone () :ObjectTask
    {
        var clone :AITaskQueue = new AITaskQueue(_repeating);
        clone._tasks = this.cloneSubtasks();

        return clone;
    }

    override public function addTask (task :ObjectTask) :void
    {
        var aiTask :AITask = (task as AITask);
        Assert.isNotNull(aiTask);

        super.addTask(aiTask);
        aiTask.parentTask = _parentTask;
    }

    /*public function addSubtask (task :AITask) :void
    {
        var topTask :AITask = this.topTask;
        if (null != topTask) {
            topTask.addSubtask(task);
        }
    }

    public function clearSubtasks () :void
    {
        var topTask :AITask = this.topTask;
        if (null != topTask) {
            topTask.clearSubtasks();
        }
    }

    public function hasSubtaskNamed (name :String) :Boolean
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.hasSubtaskNamed(name) : false);
    }

    public function hasSubtasksNamed (names :Array, index :uint = 0) :Boolean
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.hasSubtasksNamed(names, index) : false);
    }*/

    public function getStateString (depth :uint = 0) :String
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.getStateString(depth) : "[empty sequence]");
    }

    public function get name () :String
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.name : "[empty sequence]");
    }

    public function get parentTask () :AITask
    {
        return _parentTask;
    }

    public function set parentTask (parentTask :AITask) :void
    {
        _parentTask = parentTask;

        for each (var task :AITask in _tasks) {
            if (null != task) {
                task.parentTask = _parentTask;
            }
        }
    }

    protected function get topTask () :AITask
    {
        for each (var task :AITask in _tasks) {
            if (null != task) {
                return task;
            }
        }

        return null;
    }

    protected var _repeating :Boolean;
    protected var _container :TaskContainer;
    protected var _parentTask :AITask;

}

}
