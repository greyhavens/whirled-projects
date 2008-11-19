package redrover.aitask {

import com.threerings.util.Assert;

public class AITaskSequence extends AITaskTree
{
    public static const MSG_SEQUENCEDTASKCOMPLETED :String = "SequencedTaskCompleted";
    public static const MSG_SEQUENCEDTASKMESSAGE :String = "SequencedTaskMessage";

    public function AITaskSequence (repeating :Boolean = false, name :String = null)
    {
        _name = name;
        _repeating = repeating;
        _pendingTasks = [];
        _completedTasks = [];
    }

    public function addSequencedTask (task :AITask) :void
    {
        _pendingTasks.push(task);

        if (!this.hasSubtasks) {
            beginNextTask();
        }
    }

    protected function beginNextTask () :void
    {
        Assert.isTrue(_pendingTasks.length > 0);
        addSubtask(_pendingTasks[0]);
    }

    override public function update (dt :Number) :int
    {
        super.update(dt);

        // do we need to repeat?
        if (_repeating && _pendingTasks.length == 0) {
            _pendingTasks = cloneSubtasks();
            _completedTasks = [];

            if (_pendingTasks.length > 0) {
                beginNextTask();
            }
        }

        return (_pendingTasks.length > 0 ? AITaskStatus.ACTIVE : AITaskStatus.COMPLETE);
    }

    override public function get name () :String
    {
        return _name;
    }

    override public function clone () :AITask
    {
        var clone :AITaskSequence = new AITaskSequence(_repeating, _name);
        clone._pendingTasks = cloneSubtasks();

        return clone;
    }

    override protected function subtaskCompleted (task :AITask) :void
    {
        // the current subtask is stored at _pendingTasks[0]
        _pendingTasks.shift();
        _completedTasks.push(task);

        if (_pendingTasks.length > 0) {
            beginNextTask();
        }

        sendParentMessage(MSG_SEQUENCEDTASKCOMPLETED, task);
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String,
        data :Object) :void
    {
        sendParentMessage(MSG_SEQUENCEDTASKMESSAGE,
            new SequencedTaskMessage(subtask, messageName, data));
    }

    protected function cloneSubtasks () :Array
    {
        var clones :Array = [];

        for each (var task :AITask in _completedTasks) {
            clones.push(task.clone());
        }

        for each (task in _pendingTasks) {
            clones.push(task.clone());
        }

        return clones;
    }

    protected var _name :String;
    protected var _repeating :Boolean;
    protected var _pendingTasks :Array;
    protected var _completedTasks :Array;

}

}
