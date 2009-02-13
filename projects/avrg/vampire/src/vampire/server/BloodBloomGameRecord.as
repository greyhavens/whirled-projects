package vampire.server
{
    import com.threerings.util.HashSet;
    
public class BloodBloomGameRecord
{
    public function BloodBloomGameRecord( predatorId :int, preyId :int)
    {
        primaryPredator = predatorId;
        predators.add( primaryPredator );
        prey = preyId;
    }
    
    public function addPredator( playerId :int ) :void
    {
        predators.add( playerId );
    }
    
    public function isPredator( playerId :int ) :Boolean
    {
        return predators.contains( playerId );
    }
    
    public function isPrey( playerId :int ) :Boolean
    {
        return playerId == prey;
    }
    
    public function update( dt :Number ) :void
    {
        
    }
    
    public function startGame() :void
    {
        _started = true;
    }
    
    public function get isStarted() :Boolean
    {
        return _started;
    }
    
    public function get isFinished() :Boolean
    {
        return _started;
    }
    
    public var predators :HashSet = new HashSet();
    public var prey :int;
    public var primaryPredator :int;
    protected  var _started :Boolean = false;
    protected  var _finished :Boolean = false;

}
}