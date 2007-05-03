//
// $Id$

package com.threerings.flip.data;

import com.threerings.presents.dobj.DEvent;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.ObjectAccessException;

/**
 * A custom event that drops a ball on the board and increments scores.
 */
public class DropEvent extends DEvent
{
    /**
     * Suitable for unserialization.
     */
    public DropEvent ()
    {
    }

    /**
     * Construct a DropEvent.
     */
    public DropEvent (int targetOid, int slot, int pidx, int roundId, long seed)
    {
        super(targetOid);

        _slot = (byte) slot;
        _pidx = (byte) pidx;
        _roundId = roundId;
        _seed = seed;
        _onServer = true;
    }

    @Override // documentation inherited
    public boolean applyToObject (DObject target)
        throws ObjectAccessException
    {
        if (!_onServer) {
            ((FlipObject) target).addBallImpl(_slot, _pidx, _roundId, _seed);
        }
        return true;
    }

    /** The slot we're dropping into. */
    protected byte _slot;

    /** The player index of the drop. */
    protected byte _pidx;

    /** The round id. */
    protected int _roundId;

    /** The seed for this drop. */
    protected long _seed;

    /** True if this event is on the server. */
    protected transient boolean _onServer;
}
