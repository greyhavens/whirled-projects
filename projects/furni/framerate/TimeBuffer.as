package {

import flash.utils.getTimer;

public class TimeBuffer
{
    public function TimeBuffer (maxAge :int = 0, initialCapacity :int = 10)
    {
        _maxAge = maxAge;
        _array = new Array(initialCapacity);
    }

    /** Returns the number of elements currently stored in the TimeBuffer. */
    public function get length () :uint
    {
        return _length;
    }

    /** Returns true if the TimeBuffer contains 0 elements. */
    public function get empty () :Boolean
    {
        return (0 == _length);
    }

    /**
     * Sets the maximum age of items in the buffer, in milliseconds.
     * Whenever new items are added, items older than the maxAge will be removed.
     */
    public function set maxAge (val :int) :void
    {
        _maxAge = val;
        if (_maxAge > 0) {
            pruneOldEntries(flash.utils.getTimer() - _maxAge);
        }
    }

    /**
     * Adds the specified elements to the back of the TimeBuffer.
     * Returns the new length of the TimeBuffer.
     */
    public function push (...args) :uint
    {
        if (_length + args.length > _array.length) {
            setCapacity(_array.length * 2);
        }

        var timeNow :int = flash.utils.getTimer();

        if (_maxAge > 0) {
            pruneOldEntries(timeNow - _maxAge);
        }

        for (var ii :uint = 0; ii < args.length; ++ii) {
            var index :int = ((_firstIndex + _length) % _array.length);
            var entry :Entry = _array[index];
            if (entry == null) {
                entry = new Entry();
                _array[index] = entry;
            }

            entry.data = args[ii];
            entry.timestamp = timeNow;
            _length += 1;
        }

        return _length;
    }

    /**
     * Removes the first element from the TimeBuffer and returns it.
     * If the TimeBuffer is empty, shift() will return undefined.
     */
    public function shift () :*
    {
        if (this.empty) {
            return undefined;
        }

        var entry :Entry = _array[_firstIndex];
        var data :* = entry.data;
        entry.data = null;
        _firstIndex = (_firstIndex < _array.length - 1 ? _firstIndex + 1 : 0);
        --_length;

        return data;
    }

    /**
     * Removes the last element from the TimeBuffer and returns it.
     * If the TimeBuffer is empty, pop() will return undefined.
     */
    public function pop () :*
    {
        if (this.empty) {
            return undefined;
        }

        var lastIndex :int = ((_firstIndex + _length - 1) % _array.length);

        var entry :Entry = _array[lastIndex];
        var data :* = entry.data;
        entry.data = null;
        --_length;

        return data;
    }

    /** Removes all elements from the TimeBuffer. */
    public function clear () :void
    {
        for each (var entry :Entry in _array) {
            if (entry != null) {
                entry.data = null;
            }
        }

        _length = 0;
        _firstIndex = 0;
    }

    /**
     * Returns the element at the specified index.
     * If index >= length, at() will return undefined.
     */
    public function at (index :uint) :*
    {
        var entry :Entry = entryAt(index);
        return (entry == null ? undefined : entry.data);
    }

    public function timestampAt (index :uint) :int
    {
        var entry :Entry = entryAt(index);
        return (entry == null ? -1 : entry.timestamp);
    }

    /**
     * Executes a test function on each item in the ring buffer
     * until an item is reached that returns false for the specified
     * function.
     *
     * function test (data :*, timestamp :int) :Boolean
     *
     * Returns a Boolean value of true if all items in the buffer return
     * true for the specified function; otherwise, false.
     */
    public function every (callback :Function) :Boolean
    {
        for (var ii :int = 0; ii < _length; ++ii) {
            var entry :Entry = entryAt(ii);
            if (!callback(entry.data, entry.timestamp)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Executes a function on each item in the buffer.
     * function callback (data :*, timestamp :int) :void
     */
    public function forEach (callback :Function) :void
    {
        for (var ii :int = 0; ii < _length; ++ii) {
            var entry :Entry = entryAt(ii);
            callback(entry.data, entry.timestamp);
        }
    }

    /**
     * Searches for an item in the ring buffer by using strict equality
     * (===) and returns the index position of the item, or -1
     * if the item is not found.
     */
    public function indexOf (searchElement :*, fromIndex :int = 0) :int
    {
        for (var i :int = 0; i < _length; ++i) {
            if (at(i) === searchElement) {
                return i;
            }
        }

        return -1;
    }

    /**
     * Removes all entries whose age is < minTimestamp from the TimeBuffer.
     */
    public function pruneOldEntries (minTimestamp :int) :void
    {
        // Remove all entries whose age is < minTimestamp
        while (_length > 0) {
            var firstEntry :Entry = _array[_firstIndex];
            if (firstEntry.timestamp >= minTimestamp) {
                // Entries are always stored oldest to youngest, so we can stop
                // when we find the first entry that's old enough to stay.
                break;

            } else {
                firstEntry.data = null;
                _length--;
                _firstIndex = (_firstIndex < _array.length - 1 ? _firstIndex + 1 : 0);
            }
        }
    }

    protected function setCapacity (newCapacity :uint) :void
    {
        if (newCapacity == _array.length) {
            return;
        }

        // Copy existing elements to a new array.
        var newArray :Array = new Array(newCapacity);
        for (var ii :int = 0; ii < _array.length; ++ii) {
            newArray[ii] = _array[(_firstIndex + ii) % _array.length];
        }

        _length = Math.min(_length, newCapacity);
        _array = newArray;
        _firstIndex = 0;
    }

    protected function entryAt (index :uint) :Entry
    {
        return (index < _length ? _array[(_firstIndex + index) % _array.length] : null);
    }

    protected var _array :Array = [];
    protected var _length :uint;
    protected var _firstIndex :uint;
    protected var _maxAge :int;
}

}

class Entry
{
    public var timestamp :int;
    public var data :*;
}
