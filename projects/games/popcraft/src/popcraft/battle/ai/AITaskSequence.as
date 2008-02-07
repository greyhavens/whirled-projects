package popcraft.battle.ai {
    
import popcraft.battle.CreatureUnit;

public class AITaskSequence extends AITaskTree
{
    public function AITaskSequence (name :String, tasks :Array)
    {
        _name = name;
        _pendingTasks = tasks.reverse();
        
        this.beginNextTask();
    }
    
    protected function beginNextTask () :void
    {
        this.addSubtask(_pendingTasks.pop());
    }
    
    override protected function update (dt :Number, unit :CreatureUnit) :uint
    {
        super.update(dt, unit);
        
        return (_done ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }
    
    override public function get name () :String
    {
        return _name;
    }
    
    override protected function childTaskCompleted (task :AITask) :void
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