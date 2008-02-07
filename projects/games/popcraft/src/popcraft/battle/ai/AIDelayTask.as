package popcraft.battle.ai {
    
import popcraft.battle.CreatureUnit;
    
public class AIDelayTask extends AITaskBase
{
    public static const NAME :String = "Delay";
    
    public function AIDelayTask (time :Number)
    {
        _totalTime = time;
    }
    
    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        _elapsedTime += dt;
        
        return (_elapsedTime >= _totalTime ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }
    
    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
    
}

}