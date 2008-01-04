package ghostbusters.fight.core.tasks {

import com.threerings.util.Assert;

import ghostbusters.fight.core.ObjectTask;
import ghostbusters.fight.core.AppObject;

internal class TaskContainer extends ObjectTask
{
    public static const TYPE_PARALLEL :uint = 0;
    public static const TYPE_SERIAL :uint = 1;
    public static const TYPE_REPEATING :uint = 2;

    public function TaskContainer (type :uint, task1 :ObjectTask = null, task2 :ObjectTask = null)
    {
        Assert.isTrue(type == TYPE_PARALLEL || type == TYPE_SERIAL || type == TYPE_REPEATING);
        _type = type;

        if (null != task1) {
            addTask(task1);
        }
        if (null != task2) {
            addTask(task2);
        }
    }

    /** Adds a child task to the TaskContainer. */
    public function addTask (task :ObjectTask) :void
    {
        Assert.isTrue(null != task);
        _tasks.push(task);
        _completedTasks.push(null);
        _activeTaskCount += 1;
    }

    /** Removes all tasks from the TaskContainer. */
    public function removeAllTasks () :void
    {
        _tasks = new Array();
        _completedTasks = new Array();
        _activeTaskCount = 0;
    }

    /** Returns true if the TaskContainer has any child tasks. */
    public function hasTasks () :Boolean
    {
        return (_activeTaskCount > 0);
    }

    /** Updates all child tasks. */
    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var hasIncompleteTasks :Boolean = false;
        var i :int;
        for (i = 0; i < _tasks.length; ++i) {
            var task :ObjectTask = (_tasks[i] as ObjectTask);

            // we can have holes in the array
            if (null == task) {
                continue;
            }

            var complete :Boolean = task.update(dt, obj);

            if (!complete) {
                hasIncompleteTasks = true;

                // Serial and Repeating tasks proceed one task at a time
                if (_type != TYPE_PARALLEL) {
                    break;
                }

            } else {
                // the task is complete - move it the completed tasks array
                _completedTasks[i] = _tasks[i];
                _tasks[i] = null;
                _activeTaskCount -= 1;
            }
        }

        // if this is a repeating task and all its tasks have been completed, start over again
        if (_type == TYPE_REPEATING && !hasIncompleteTasks && _completedTasks.length > 0) {
            _tasks = new Array(_completedTasks.length);

            for (i = 0; i < _completedTasks.length; ++i) {
                var completedTask :ObjectTask = (_completedTasks[i] as ObjectTask);
                Assert.isNotNull(completedTask);
                _tasks[i] = completedTask.clone();
            }

            _completedTasks = new Array(_tasks.length);

            hasIncompleteTasks = true;

            _activeTaskCount = _tasks.length;
        }

        return (!hasIncompleteTasks);
    }

    /** Returns a clone of the TaskContainer. */
    override public function clone () :ObjectTask
    {
        var theClone :TaskContainer = new TaskContainer(_type);

        Assert.isTrue(_tasks.length == _completedTasks.length);

        // clone each child task and put it in the cloned container
        for (var i:int = 0; i < _tasks.length; ++i) {
            var task :ObjectTask = (null != _tasks[i] ? _tasks[i] as ObjectTask : _completedTasks[i] as ObjectTask);
            Assert.isNotNull(task);
            theClone.addTask(task.clone());
        }

        return theClone;
    }

    protected var _type :int;
    protected var _tasks :Array = new Array();
    protected var _completedTasks :Array = new Array();
    protected var _activeTaskCount :uint;
}

}
