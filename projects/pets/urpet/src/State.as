//
// $Id$

package {

import com.threerings.util.HashMap;

/**
 * Represents information about a Pet state.
 */
public class State
{
    // our various emotional states
    public static const CONTENT :State = new State("content");
    public static const PLAYFUL :State = new State("playful");
    public static const SLEEPY :State = new State("sleepy");
    public static const SLEEPING :State = new State("sleeping", false);
    public static const LONELY :State = new State("lonely");
    public static const HUNGRY :State = new State("hungry");
    public static const CURIOUS :State = new State("curious");
    public static const EXCITED :State = new State("excited");

    /**
     * Returns the state with the specified name or null if no state with that name exists.
     */
    public static function getState (name :String) :State
    {
        return (_states.get(name) as State);
    }

    /**
     * Enumerates all known states.
     */
    public static function enumerateStates () :Array
    {
        return _states.values();
    }

    /** The string identifier for this state. */
    public var name :String;

    /** The states to which we can legally transition from this state. */
    public var transitions :Array;

    /** Whether or not we can walk while in this state. */
    public var canWalk :Boolean;

    /** Don't call this, use the constants. */
    public function State (name :String, canWalk :Boolean = true)
    {
        this.name = name;
        this.canWalk = canWalk;

        // yay for wacky static initializer execution order
        if (_states == null) {
            _states = new HashMap();
        }
        _states.put(name, this);
    }

    /** Generates a string representation of this instance. */
    public function toString () :String
    {
        return name;
    }

    /** Called from a static initializer to set up our transitions. */
    protected static function registerTransitions () :void
    {
        CONTENT.transitions = [ PLAYFUL, EXCITED, CURIOUS, HUNGRY, LONELY ];
        PLAYFUL.transitions = [ CONTENT, SLEEPY, EXCITED ];
        SLEEPY.transitions = [ SLEEPING ];
        SLEEPING.transitions = [ CONTENT ];
        LONELY.transitions = [ CONTENT, SLEEPY ];
        HUNGRY.transitions = [ CONTENT, LONELY, CURIOUS ];
        CURIOUS.transitions = [ CONTENT, HUNGRY, EXCITED ];
        EXCITED.transitions = [ CONTENT, PLAYFUL, CURIOUS ];
    }

    protected static var _states :HashMap;

    // we have to do this after our constants are all initialized
    registerTransitions();
}
}
