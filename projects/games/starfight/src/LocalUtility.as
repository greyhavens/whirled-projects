package {

public interface LocalUtility
{
    function resetScores () :void;
    function setScore (playerId :int, score :int) :void;
    function incrementScore (playerId :int, delta :int) :void;
    function feedback (msg :String) :void;
}

}
