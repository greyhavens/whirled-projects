package vampire.quest.client.npctalk {

public interface Statement
{
    // returns the amount of time the update took, up to dt
    function update (dt :Number) :Number;
    function get isDone () :Boolean;
}

}
