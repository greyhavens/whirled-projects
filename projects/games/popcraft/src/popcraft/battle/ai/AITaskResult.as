package popcraft.battle.ai {
    
public class AITaskResult
{
    public function AITaskResult (name :String, data :*)
    {
        _name = name;
        _data = data;
    }
    
    public function get name () :String
    {
        return _name;
    }
    
    public function get data () :*
    {
        return _data;
    }
    
    protected var _name :String;
    protected var _data :*;

}

}