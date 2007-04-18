//
// $Id$

package {

/**
 * Represents information about a Pet state.
 */
public class State
{
    /** All possible states. */
    public static const STATES :Array = [
        new State("content", [ "playful", "excited", "curious", "hungry", "lonely", "sleepy" ]),
        new State("playful", [ "content", "sleepy", "excited" ]),
        new State("sleepy", [ "content", "sleeping" ]),
        new State("sleeping", [ "content" ], false),
        new State("lonely", [ "content", "sleepy" ]),
        new State("hungry", [ "content", "lonely", "curious" ]),
        new State("curious", [ "content", "hungry", "excited" ]),
        new State("excited", [ "content", "playful", "curious" ])
        ];

    /** The string identifier for this state. */
    public var name :String;

    /** The names of states to which we can legally transition from this state. */
    public var transitions :Array;

    /** Whether or not we can walk while in this state. */
    public var canWalk :Boolean;

    protected function State (name :String, transitions :Array, canWalk :Boolean = true)
    {
        this.name = name;
        this.transitions = transitions;
        this.canWalk = canWalk;
    }
}
}
