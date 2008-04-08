package popcraft.battle.ai {

import popcraft.battle.CreatureUnit;

public class AITaskSequence extends AITaskTree
{
    public function AITaskSequence (name :String)
    {
        _name = name;
        _pendingTasks = [];
    }

    public function addSequencedTask (task :AITask)
    {
        _pendingTasks.push(task);

        if (!this.hasSubtasks) {
            this.beginNextTask();
        }
    }

    protected function beginNextTask () :void
    {
        this.addSubtask(_pendingTasks.shift());
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        super.update(dt, unit);

        return (_done ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }

    override public function get name () :String
    {
        return _name;
    }

    override protected function subtaskCompleted (task :AITask) :void
    {
        _done = (_pendingTasks.length == 0);

        if (!_done) {
            this.beginNextTask();
        }
    }

    protected var _name :String;
    protected var _pendingTasks :Array;
    protected var _done :Boolean;

}

}
