package popcraft.battle.ai {
    
import popcraft.battle.CreatureUnit;
    
public class AIDelayTask
    implements AITask
{
    public static const DEFAULT_NAME :String = "Delay";
    
    public function AIDelayTask (time :Number, taskName :String = DEFAULT_NAME)
    {
        _totalTime = time;
        
        _name = taskName;
    }
    
    public function update (dt :Number, unit :CreatureUnit) :uint
    {
        _elapsedTime += dt;
        
        return (_elapsedTime >= _totalTime ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }
    
    public function get name () :String
    {
        return _name;
    }
    
    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
    
    protected var _name :String;
    
}

}