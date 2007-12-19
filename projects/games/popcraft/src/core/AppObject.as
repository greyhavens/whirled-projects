package core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;

import core.tasks.ParallelTask;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.DisplayObjectContainer;

public class AppObject
{
    /**
     * Returns the id that uniquely identifies this object in its containing AppMode.
     */
    public final function get id () :uint
    {
        return _objectId;
    }

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
     * Returns the DisplayObjectContainer attached to this AppObject,
     * if one exists, and null otherwise. Defaults to
     * (displayObject as DisplayObjectContainer)
     */
    public function get displayObjectContainer () :DisplayObjectContainer
    {
        return (this.displayObject as DisplayObjectContainer);
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
     * The groups are returned as an Array of Strings.
     * Objects cannot change their group membership once added to a mode.
     */
    public function get objectGroups () :Array
    {
        return new Array();
    }

    /** Returns true if the object is in the specified group. */
    public function isInGroup (groupName :String) :Boolean
    {
        return this.objectGroups.contains(groupName);
    }

    /** Removes the AppObject from its parent mode. */
    public function destroySelf() :void
    {
        _parentMode.removeObject(_objectId);
    }

    /** Adds an unnamed task to this AppObject. */
    public function addTask (task :ObjectTask) :void
    {
        Assert.isTrue(null != task);
        _anonymousTasks.addTask(task);
    }

    /** Adds a named task to this AppObject. */
    public function addNamedTask (name :String, task :ObjectTask) :void
    {
        Assert.isTrue(null != task);
        Assert.isTrue(null != name);
        Assert.isTrue(name.length > 0);

        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
        if (null == namedTaskContainer) {
            namedTaskContainer = new ParallelTask();
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
    public function removeNamedTasks (name :String) :void
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
                if ((namedTaskContainer as ParallelTask).hasTasks()) {
                    return true;
                }
            }
        }

        return false;
    }

    /** Returns true if the AppObject has any tasks with the given name. */
    public function hasTasksNamed (name :String) :Boolean
    {
        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
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
    protected function addedToMode (mode :AppMode) :void
    {
    }

    /**
     * Called immediately after the AppObject has been removed from an AppMode.
     * (Subclasses can override this to do something useful.)
     */
    protected function removedFromMode (mode :AppMode) :void
    {
    }

    internal function addedToModeInternal (mode :AppMode) :void
    {
        addedToMode(mode);
    }

    internal function removedFromModeInternal (mode :AppMode) :void
    {
        removedFromMode(mode);
    }

    internal function updateInternal(dt :Number) :void
    {
        _anonymousTasks.update(dt, this);

        var thisAppObject :AppObject = this;
        _namedTasks.forEach(updateNamedTaskContainer);

        update(dt);

        function updateNamedTaskContainer (name :*, tasks:*) :void {
            (tasks as ParallelTask).update(dt, thisAppObject);
        }
    }

    protected var _anonymousTasks :ParallelTask = new ParallelTask();
    protected var _namedTasks :HashMap = new HashMap();

    // managed by AppMode
    internal var _objectId :uint = 0xFFFFFFFF;
    internal var _parentMode :AppMode;
}

}
