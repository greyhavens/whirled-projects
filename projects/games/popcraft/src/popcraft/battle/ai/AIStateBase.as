package popcraft.battle.ai {
    
import com.threerings.util.Assert;
import com.whirled.contrib.core.*;

import popcraft.battle.CreatureUnit;
    
public class AIStateBase
    implements AIState
{
    public function AIStateBase ()
    {
    }
    
    /** Subclasses must implement this. */
    public function get name () :String
    {
        Assert.fail("name() is not implemented");
        return null;
    }

    public function receiveMessage (msg :ObjectMessage) :AIState
    {
        return this;
    }

    public function update (dt :Number, unit :CreatureUnit) :AIState
    {
        return this;
    }

    public function get parentState () :AIStateTree
    {
        return _parentState;
    }

    public function set parentState (state :AIStateTree) :void
    {
        _parentState = state;
    }
    
    protected var _parentState :AIStateTree;

}

}