package popcraft.battle.ai {
    
import com.threerings.util.Assert;

import com.whirled.contrib.core.*;
    
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

    /** Subclasses must implement this if they will be cloned. */
    public function clone () :ObjectTask
    {
        Assert.fail("clone() is not implemented");
        return null;
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    public function update (dt :Number, obj :AppObject) :Boolean
    {
        return false;
    }

    public function get parentState () :AIStateTree
    {
        return _parentState;
    }

    public function set parentState (state :AIStateTree) :void
    {
        _parentState = state;
    }
    
    public function transitionTo (nextState :AIState) :void
    {
        Assert.isNotNull(_parentState, "root AIStates cannot transition");
        _parentState.handleTransition(this, nextState);
    }
    
    protected var _parentState :AIStateTree;

}

}