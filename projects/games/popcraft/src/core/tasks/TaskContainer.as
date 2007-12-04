package core.tasks {

import com.threerings.util.Assert;

import core.ObjectTask;
import core.AppObject;

public class TaskContainer extends ObjectTask
{
    public static const TYPE_PARALLEL :uint = 0;
    public static const TYPE_SERIAL :uint = 1;

    public static function CreateSerialTask (task1 :ObjectTask = null, task2 :ObjectTask = null) :TaskContainer
    {
        var container :TaskContainer = new TaskContainer(TYPE_SERIAL);
        if (null != task1) {
            container.addTask(task1);
        }
        if (null != task2) {
            container.addTask(task2);
        }

        return container;
    }

    public static function CreateParallelTask (task1 :ObjectTask = null, task2 :ObjectTask = null) :TaskContainer
    {
        var container :TaskContainer = new TaskContainer(TYPE_PARALLEL);
        if (null != task1) {
            container.addTask(task1);
        }
        if (null != task2) {
            container.addTask(task2);
        }

        return container;
    }

    public function TaskContainer (type :uint)
    {
        Assert.isTrue(type == TYPE_PARALLEL || type == TYPE_SERIAL);
        _type = type;
    }

    /** Adds a child task to the TaskContainer. */
    public function addTask (task :ObjectTask) :void
    {
        Assert.isTrue(null != task);
        _tasks.push(task);
    }

    /** Removes all tasks from the TaskContainer. */
    public function removeAllTasks () :void
    {
        _tasks = new Array();
    }

    /** Returns true if the TaskContainer has any child tasks. */
    public function hasTasks () :Boolean
    {
        return (_tasks.length > 0);
    }

    /** Updates all child tasks. */
    override public function update (dt :Number, obj :AppObject) :uint
    {
        var hasIncompleteTasks :Boolean = false;

        for (var i :int = 0; i < _tasks.length; ++i) {
            var task :ObjectTask = (_tasks[i] as ObjectTask);
            Assert.isTrue(null != task);

            var status :int = task.update(dt, obj);

            if (status == ObjectTask.STATUS_INCOMPLETE) {
                hasIncompleteTasks = true;

                // Serial tasks proceed one task at a time
                if (_type == TYPE_SERIAL) {
                    break;
                }

            } else {
                // the task is complete - remove it
                _tasks.splice(i, 1);
                i -= 1; // back up the index
            }
        }

        return (hasIncompleteTasks ? STATUS_INCOMPLETE : STATUS_COMPLETE);
    }

    /** Returns a clone of the TaskContainer. */
    override public function clone () :ObjectTask
    {
        var theClone :TaskContainer = new TaskContainer(_type);

        // clone each child task and put it in the cloned container
        for each (var t :* in _tasks) {
            theClone.addTask((t as ObjectTask).clone());
        }

        return theClone;
    }

    protected var _type :int;
    protected var _tasks :Array = new Array();
}

}
