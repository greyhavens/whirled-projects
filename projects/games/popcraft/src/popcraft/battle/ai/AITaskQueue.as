package popcraft.battle.ai {

import com.threerings.util.Assert;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;

public class AITaskQueue extends TaskContainer
    implements AIState
{
    public function AITaskQueue (repeating :Boolean)
    {
        super(repeating ? TaskContainer.TYPE_REPEATING : TaskContainer.TYPE_SERIAL);
        _repeating = repeating;
    }

    override public function clone () :ObjectTask
    {
        var clone :AITaskQueue = new AITaskQueue(_repeating);
        clone._tasks = this.cloneSubtasks();

        return clone;
    }

    override public function addTask (task :ObjectTask) :void
    {
        var aiState :AIState = (task as AIState);
        Assert.isNotNull(aiState);

        super.addTask(aiState);
        aiState.parentState = _parentState;
    }

    public function get name () :String
    {
        var topTask :AIState = this.topTask;
        return (null != topTask ? topTask.name : "[empty sequence]");
    }

    public function get parentState () :AIStateTree
    {
        return _parentState;
    }

    public function set parentState (parentState :AIStateTree) :void
    {
        _parentState = parentState;

        for each (var task :AIState in _tasks) {
            if (null != task) {
                task.parentState = _parentState;
            }
        }
    }
    
    public function transitionTo (nextState :AIState) :void
    {
        Assert.isNotNull(_parentState, "root AIStates cannot transition");
        _parentState.handleTransition(this, nextState);
    }

    protected function get topTask () :AIState
    {
        for each (var task :AIState in _tasks) {
            if (null != task) {
                return task;
            }
        }

        return null;
    }

    protected var _repeating :Boolean;
    protected var _container :TaskContainer;
    protected var _parentState :AIStateTree;

}

}
