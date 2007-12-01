package core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;

import flash.display.Sprite;
import core.tasks.TaskContainer;

public class AppObject extends Sprite
{
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
     * Returns the set of roles that this object belongs to.
     * Objects channot change their role array once added to a mode.
     */
    public function get objectRoles () :Array
    {
        return new Array();
    }

    /** Returns true if the object has the given role. */
    public function hasRole (role :String) :Boolean
    {
        // TODO: implement this
        Assert.isTrue(false);
        return false;
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

    internal function updateInternal(dt :Number) :void
    {
        _anonymousTasks.update(dt, this);
        update(dt);
    }

    protected var _anonymousTasks :TaskContainer = new TaskContainer(TaskContainer.TYPE_PARALLEL);
    protected var _namedTasks :HashMap = new HashMap();

    // these variables are managed by AppMode and shouldn't be modified
    internal var _parentMode :AppMode;
    internal var _modeIndex :int = -1;

}

}
