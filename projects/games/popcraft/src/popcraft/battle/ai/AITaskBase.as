package popcraft.battle.ai {
    
import com.threerings.util.Assert;
import com.whirled.contrib.core.*;

import popcraft.battle.CreatureUnit;
    
public class AITaskBase
    implements AITask
{
    public function AITaskBase ()
    {
    }
    
    /** Subclasses must implement this. */
    public function get name () :String
    {
        Assert.fail("name() is not implemented");
        return null;
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    public function update (dt :Number, unit :CreatureUnit) :Boolean
    {
        return false;
    }

    public function get parentTask () :AITaskTree
    {
        return _parentState;
    }

    public function set parentTask (state :AITaskTree) :void
    {
        _parentState = state;
    }
    
    protected var _parentState :AITaskTree;

}

}