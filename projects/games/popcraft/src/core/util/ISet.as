package core.util {

public interface ISet
{
    /**
     * Adds the specified element to the set if it's not already present.
     * Returns true if the set did not already contain the specified element.
     */
    function add (o :Object) :Boolean;

    /**
     * Removes the specified element from this set if it is present.
     * Returns true if the set contained the specified element.
     */
    function remove (o :Object) :Boolean;

    /** Remove all elements from this set. */
    function clear () :void;

    /** Returns true if this set contains the specified element. */
    function contains (o :Object) :Boolean;

    /** Retuns the number of elements in this set. */
    function size () :int; // @TSC - should this be uint?

    /** Returns true if this set contains no elements. */
    function isEmpty () :Boolean;

    /**
     * Returns all elements in the set in an Array.
     * Modifying the returned Array will not modify the set.
     */
    function toArray () :Array;
}

}
