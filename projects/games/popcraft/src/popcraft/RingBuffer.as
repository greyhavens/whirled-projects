package popcraft {

public class RingBuffer
{
    /** Creates a new RingBuffer with the specified capacity. */
    public function RingBuffer (capacity :uint = 1)
    {
        _capacity = capacity;
        _array.length = _capacity;
    }

    /** Returns the capacity of the RingBuffer. */
    public function get capacity () :uint
    {
        return _capacity;
    }

    /**
     * Sets the capacity of the RingBuffer.
     * If the new capacity is less than the RingBuffer's length,
     * elements will be removed from the end of the RingBuffer
     * to accommodate the smaller capacity.
     */
    public function set capacity (newCapacity :uint) :void
    {
        // Copy all the elements to a new array.
        var newArray :Array = new Array();
        var newLength :uint = Math.min(_length, newCapacity);
        newArray.length = newCapacity;
        for (var i :uint = 0; i < newLength; ++i) {
            newArray[i] = this.at(i);
        }

        _capacity = newCapacity;
        _length = newLength;
        _array = newArray;
        _firstIndex = 0;
    }

    /** Returns the number of elements currently stored in the RingBuffer. */
    public function get length () :uint
    {
        return _length;
    }

    /** Returns true if the RingBuffer contains 0 elements. */
    public function get empty () :Boolean
    {
        return (0 == _length);
    }

    /**
     * Adds the specified elements to the front of the RingBuffer.
     * If the RingBuffer's length is equal to its capacity, this
     * will cause elements to be removed from the back of
     * the RingBuffer.
     * Returns the new length of the RingBuffer.
     */
    public function unshift (...args) :uint
    {
        for (var i :int = args.length - 1; i >= 0; --i) {
            var index :uint = (_firstIndex > 0 ? _firstIndex - 1 : _capacity - 1);
            _array[index] = args[i];
            _length = Math.min(_length + 1, _capacity);
            _firstIndex = index;
        }

        return _length;
    }

    /**
     * Adds the specified elements to the back of the RingBuffer.
     * If the RingBuffer's length is equal to its capacity, this
     * will cause a elements to be removed from the front of
     * the RingBuffer.
     * Returns the new length of the RingBuffer.
     */
    public function push (...args) :uint
    {
        for (var i :uint = 0; i < args.length; ++i) {
            var index :uint = ((_firstIndex + _length) % _capacity);
            _array[index] = args[i];
            _length = Math.min(_length + 1, _capacity);

            // did we overwrite the first index?
            if (index == _firstIndex && _length == _capacity) {
                _firstIndex = (_firstIndex < _capacity - 1 ? _firstIndex + 1 : 0);
            }
        }

        return _length;
    }

    /**
     * Removes the first element from the RingBuffer and returns it.
     * If the RingBuffer is empty, shift() will return undefined.
     */
    public function shift () :*
    {
        if (this.empty) {
            return undefined;
        }

        var obj :* = _array[_firstIndex];
        _array[_firstIndex] = undefined;
        _firstIndex = (_firstIndex < _capacity - 1 ? _firstIndex + 1 : 0);
        --_length;

        return obj;
    }

    /**
     * Removes the last element from the RingBuffer and returns it.
     * If the RingBuffer is empty, pop() will return undefined.
     */
    public function pop () :*
    {
        if (this.empty) {
            return undefined;
        }

        var lastIndex :uint = ((_firstIndex + _length - 1) % _capacity);

        var obj :* = _array[lastIndex];
        _array[lastIndex] = undefined;
        --_length;

        return obj;
    }

    /** Removes all elements from the RingBuffer. */
    public function clear () :void
    {
        _array = new Array();
        _array.length = _capacity;
        _length = 0;
        _firstIndex = 0;
    }

    /**
     * Returns the element at the specified index.
     * If index >= length, at() will return undefined.
     */
    public function at (index :uint) :*
    {
        if (index >= _length) {
            return undefined;
        } else {
            var index :uint = ((_firstIndex + index) % _capacity);
            return _array[index];
        }
    }

    protected var _array :Array = new Array();
    protected var _capacity :uint;
    protected var _length :uint;
    protected var _firstIndex :uint;
}

}
