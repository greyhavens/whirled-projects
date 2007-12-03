package core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;

import core.util.ObjectSet;

public class AppMode
{
    public function AppMode ()
    {
    }

    /** Adds an AppObject to the mode. The AppObject must not be owned by another mode. */
    public function addObject (obj :AppObject) :void
    {
        Assert.isTrue(null != obj);
        Assert.isTrue(null == obj._parentMode);

        // if there's no free slot in our objects array,
        // make a new one
        if (_freeIndexes.length == 0) {
            _freeIndexes.push(_objects.length);
            _objects.push(null);
        }

        Assert.isTrue(_freeIndexes.length > 0);
        var index :int = _freeIndexes.pop();
        Assert.isTrue(index >= 0 && index < _objects.length);
        Assert.isTrue(_objects[index] == null);

        _objects[index] = obj;

        obj._parentMode = this;
        obj._modeIndex = index;

        // does the object have a name?
        if (null != obj.objectName) {
            Assert.isTrue(_namedObjects.get(obj.objectName) == null, "Can't add two objects with the same name to the same mode.");
            _namedObjects.put(obj.objectName, obj);
        }

        // is the object in any groups?
        var groups :HashSet = obj.objectGroups;
        if (null != groups) {
            var groupList :Array = groups.toArray();
            for each (var group :* in groupList) {
                var groupSet :ObjectSet = (_groupedObjects.get(group) as ObjectSet);
                if (null != groupSet) {
                    groupSet = new ObjectSet();
                    _groupedObjects.put(group, groupSet);
                }

                groupSet.add(obj);
            }
        }
    }

    /** Removes an AppObject from the mode. The AppObject must be owned by this mode. */
    public function removeObject (obj :AppObject) :void
    {
        // lots o' sanity checks
        Assert.isTrue(null != obj);
        Assert.isTrue(this == obj._parentMode);
        Assert.isTrue(obj._modeIndex >= 0 && obj._modeIndex < _objects.length);
        Assert.isTrue(_objects[obj._modeIndex] == obj);

        _objects[obj._modeIndex] = null;
        _freeIndexes.unshift(obj._modeIndex); // we have a new free index

        obj._parentMode = null;
        obj._modeIndex = -1;

        // does the object have a name?
        if (null != obj.objectName) {
            Assert.isTrue(_namedObjects.get(obj.objectName) == obj);
            _namedObjects.put(obj.objectName, null);
        }

        // is the object in any groups?
        var groups :HashSet = obj.objectGroups;
        if (null != groups) {
            var groupList :Array = groups.toArray();

            for each (var group :* in groupList) {
                var groupSet :ObjectSet = (_groupedObjects.get(group) as ObjectSet);
                Assert.isTrue(null != groupSet);
                var wasInSet :Boolean = groupSet.remove(obj);
                Assert.isTrue(wasInSet);
            }
        }
    }

    /** Returns the object in this mode with the given name, or null if no such object exists. */
    public function getObjectNamed (name :String) :AppObject
    {
        return (_namedObjects.get(name) as AppObject);
    }

    /** Returns the set of objects in the given group. This set must not be modified by client code. */
    public function getObjectsInGroup (role :String) :ObjectSet
    {
        var objects :ObjectSet = (_groupedObjects.get(role) as ObjectSet);

        return (null != objects ? objects : new ObjectSet());
    }

    /** Called once per update tick. Updates all objects in the mode. */
    public function update (dt :Number) :void
    {
        // update all objects in this mode
        // there may be holes in the array, so check each object against null
        for each (var obj:* in _objects) {
            if (null != obj) {
                (obj as AppObject).updateInternal(dt);
            }
        }
    }

    /** Called when the mode is added to the mode stack */
    public function setup () :void
    {
    }

    /** Called when the mode is removed from the mode stack */
    public function destroy () :void
    {
    }

    /** Called when the mode becomes active on the mode stack */
    public function enter () :void
    {
    }

    /** Called when the mode becomes inactive on the mode stack */
    public function exit () :void
    {
    }

    protected var _objects :Array = new Array();
    protected var _freeIndexes :Array = new Array();

    /** stores a mapping from String to Object */
    protected var _namedObjects :HashMap = new HashMap();

    /** stores a mapping from String to ObjectSet */
    protected var _groupedObjects :HashMap = new HashMap();
}

}
