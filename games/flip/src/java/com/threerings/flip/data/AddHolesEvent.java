//
// $Id$

package com.threerings.flip.data;

import com.threerings.presents.dobj.DEvent;
import com.threerings.presents.dobj.DObject;

/**
 * An event sent by the server when holes should be added to the board.
 */
public class AddHolesEvent extends DEvent
{
    /** Suitable for unserialization. */
    public AddHolesEvent ()
    {
    }

    /**
     * Construct an AddHolesEvent.
     */
    public AddHolesEvent (int targetOid, int numAdd, int numRemove, long seed)
    {
        super(targetOid);

        _numAdd = numAdd;
        _numRemove = numRemove;
        _seed = seed;
        _onServer = true;
    }

    @Override // documentation inherited
    public boolean applyToObject (DObject target)
    {
        if (!_onServer) {
            ((FlipObject) target).addHolesImpl(_numAdd, _numRemove, _seed);
        }
        return true;
    }

    /** The number of holes to add/remove. */
    protected int _numAdd, _numRemove;

    /** The seed for generating the random holes. */
    protected long _seed;

    /** True if this event is on the server. */
    protected transient boolean _onServer;
}
