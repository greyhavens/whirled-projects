package core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;

import core.tasks.TaskContainer;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;

public class AppObject
{
    /**
     * Returns the DisplayObject attached to this AppObject,
     * if one exists, and null otherwise. Default to null.
     */
    public function get displayObject () :DisplayObject
    {
        return null;
    }

    /**
     * Returns the InteractiveObject attached to this AppObject,
     * if one exists, and null otherwise. Defaults to
     * (displayObject as InteractiveObject).
     */
    public function get interactiveObject () :InteractiveObject
    {
        return (this.displayObject as InteractiveObject);
    }

    /**
     * Returns the name of this object.
     * Two objects in the same mode cannot have the same name.
     * Objects cannot change their names once added to a mode.
     */
    public function get objectName () :String
    {
        return null;
    }

    /**
     * Returns the set of groups that this object belongs to.
     * The groups are returned as a HashSet of Strings.
     * Objects cannot change their group membership once added to a mode.
     */
    public function get objectGroups () :HashSet
    {
        return new HashSet();
    }

    /** Returns true if the object is in the specified group. */
    public function isInGroup (role :String) :Boolean
    {
        return this.objectGroups.contains(role);
    }

    /** Removes the AppObject from its parent mode. */
    public function removeSelf() :void
    {
        Assert.isTrue(null != _parentMode);
        _parentMode.removeObject(this);
    }

    /** Adds an unnamed task to this AppObject. */
    public function addTask (task :ObjectTask) :void
    {
        Assert.isTrue(null != task);
        _anonymousTasks.addTask(task);
    }

    /** Adds a named task to this AppObject. */
    public function addNamedTask (task :ObjectTask, name :String) :void
    {
        Assert.isTrue(null != task);
        Assert.isTrue(null != name);
        Assert.isTrue(name.length > 0);

        var namedTaskContainer :TaskContainer = (_namedTasks.get(name) as TaskContainer);
        if (null == namedTaskContainer) {
            namedTaskContainer = new TaskContainer(TaskContainer.TYPE_PARALLEL);
            _namedTasks.put(name, namedTaskContainer);
        }

        namedTaskContainer.addTask(task);
    }

    /** Removes all tasks from the AppObject. */
    public function removeAllTasks () :void
    {
        _anonymousTasks.removeAllTasks();
        _namedTasks.clear();
    }

    /** Removes all tasks with the given name from the AppObject. */
    public function removedNamedTasks (name :String) :void
    {
        Assert.isTrue(null != name);
        Assert.isTrue(name.length > 0);

        _namedTasks.remove(name);
    }

    /** Returns true if the AppObject has any tasks. */
    public function hasTasks () :Boolean
    {
        if (_anonymousTasks.hasTasks()) {
            return true;
        } else {
            for each (var namedTaskContainer :* in _namedTasks) {
                if ((namedTaskContainer as TaskContainer).hasTasks()) {
                    return true;
                }
            }
        }

        return false;
    }

    /** Returns true if the AppObject has any tasks with the given name. */
    public function hasTasksNamed (name :String) :Boolean
    {
        var namedTaskContainer :TaskContainer = (_namedTasks.get(name) as TaskContainer);
        return (null == namedTaskContainer ? false : namedTaskContainer.hasTasks());
    }

    /** Called once per update tick. (Subclasses can override this to do something useful.) */
    protected function update (dt :Number) :void
    {
    }

    /**
     * Called immediately after the AppObject has been added to an AppMode.
     * (Subclasses can override this to do something useful.)
     */
    public function addedToMode (mode :AppMode) :void
    {
    }

    /**
     * Called immediately after the AppObject has been removed from an AppMode.
     * (Subclasses can override this to do something useful.)
     */
    public function removedFromMode (mode :AppMode) :void
    {
    }

    internal function updateInternal(dt :Number) :void
    {
        _anonymousTasks.update(dt, this);
        _namedTasks.forEach(updateNamedTaskContainer);
        update(dt);

        function updateNamedTaskContainer (name :*, tasks:*) :void {
            (tasks as TaskContainer).update(dt, this);
        }
    }

    protected var _anonymousTasks :TaskContainer = new TaskContainer(TaskContainer.TYPE_PARALLEL);
    protected var _namedTasks :HashMap = new HashMap();

    // these variables are managed by AppMode and shouldn't be modified
    internal var _parentMode :AppMode;
    internal var _modeIndex :int = -1;

}

}
