package popcraft.battle.ai {

import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.ObjectTask;    
    
public class AIDelayTask extends AIStateTree
{
    public function AIDelayTask (delayTime :Number)
    {
        _totalTime = delayTime;
    }
    
    override public function get name () :String
    {
        return "DelayTask (" + _totalTime + ")";
    }
    
    override public function clone () :ObjectTask
    {
        return new AIDelayTask(_totalTime);
    }
    
    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);
        
        _elapsedTime += dt;
        
        return (_elapsedTime >= _totalTime && this.subtasksComplete);
    }
    
    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
    
}

}