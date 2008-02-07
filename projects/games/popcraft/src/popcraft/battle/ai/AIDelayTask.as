package popcraft.battle.ai {
    
import popcraft.battle.CreatureUnit;
    
public class AIDelayTask
    implements AITask
{
    public static const NAME :String = "Delay";
    
    public function AIDelayTask (time :Number)
    {
        _totalTime = time;
    }
    
    public function update (dt :Number, unit :CreatureUnit) :uint
    {
        _elapsedTime += dt;
        
        return (_elapsedTime >= _totalTime ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }
    
    function get name () :String
    {
        return NAME;
    }
    
    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
    
}

}