package core.util {

import flash.utils.Dictionary;

public class ObjectSet
    implements ISet
{
    /**
     * Adds the specified element to the set if it's not already present.
     * Returns true if the set did not already contain the specified element.
     */
    public function add (o :Object) :Boolean
    {
        if (this.contains(o)) {
            return false;
        } else {
            _dict[o] = null;
            ++_size;
            return true;
        }
    }

    /**
     * Removes the specified element from this set if it is present.
     * Returns true if the set contained the specified element.
     */
    public function remove (o :Object) :Boolean
    {
        if (this.contains(o)) {
            delete _dict[o];
            --_size;
            return true;
        } else {
            return false;
        }
    }

    /** Remove all elements from this set. */
    public function clear () :void
    {
        for (var key :* in _dict) {
            delete _dict[key];
        }

        _size = 0;
    }

    /** Returns true if this set contains the specified element. */
    public function contains (o :Object) :Boolean
    {
        return (undefined !== _dict[o]);
    }

    /** Retuns the number of elements in this set. */
    public function size () :int
    {
        return _size;
    }

    /** Returns true if this set contains no elements. */
    public function isEmpty () :Boolean
    {
        return (0 == _size);
    }

    /**
     * Returns all elements in the set in an Array.
     * Modifying the returned Array will not modify the set.
     */
    public function toArray () :Array
    {
        var arr :Array = new Array();

        for (var key :* in _dict) {
            arr.push(key);
        }

        return arr;
    }

    protected var _dict :Dictionary = new Dictionary();
    protected var _size :int = 0;
}

}
