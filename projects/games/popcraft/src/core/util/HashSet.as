package core.util {

import com.threerings.util.HashMap;

public class HashSet
   implements ISet
{
    /**
     * Construct a HashSet
     *
     * @param loadFactor - A measure of how full the hashtable is allowed to
     *                     get before it is automatically resized. The default
     *                     value of 1.75 should be fine.
     * @param equalsFn   - (Optional) A function to use to compare object
     *                     equality for keys that are neither simple nor
     *                     implement Hashable. The signature should be
     *                     "function (o1, o2) :Boolean".
     * @param hashFn     - (Optional) A function to use to generate a hash
     *                     code for keys that are neither simple nor
     *                     implement Hashable. The signature should be
     *                     "function (obj) :*", where the return type is
     *                     numeric or String. Two objects that are equals
     *                     according to the specified equalsFn *must*
     *                     generate equal values when passed to the hashFn.
     */
    public function HashSet (
            loadFactor :Number = 1.75,
            equalsFn :Function = null,
            hashFn :Function = null)
    {
        _hashMap = new HashMap(loadFactor, equalsFn, hashFn);
    }

    public function add (o :Object) :Boolean
    {
        var previousValue :* = _hashMap.put(o, null);

        // return true if the key did not already
        // exist in the Set
        return (undefined === previousValue);
    }

    public function remove (o :Object) :Boolean
    {
        var previousValue :* = _hashMap.remove(o);

        // return true if the key existed in the Set
        return (undefined !== previousValue);
    }

    public function clear () :void
    {
        _hashMap.clear();
    }

    public function contains (o :Object) :Boolean
    {
        return (_hashMap.containsKey(o));
    }

    public function size () :int
    {
        return (_hashMap.size());
    }

    public function isEmpty () :Boolean
    {
        return (_hashMap.isEmpty());
    }

    public function toArray () :Array
    {
        return (_hashMap.keys());
    }

    protected var _hashMap :HashMap;
}
}
