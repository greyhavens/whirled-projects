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

    public function receiveMessage (msg :ObjectMessage) :uint
    {
        return AITaskStatus.ACTIVE;
    }

    public function update (dt :Number, unit :CreatureUnit) :uint
    {
        return AITaskStatus.ACTIVE;
    }

    public function get parentTask () :AITaskTree
    {
        return _parentTask;
    }

    public function set parentTask (task :AITaskTree) :void
    {
        _parentTask = task;
    }
    
    protected var _parentTask :AITaskTree;

}

}