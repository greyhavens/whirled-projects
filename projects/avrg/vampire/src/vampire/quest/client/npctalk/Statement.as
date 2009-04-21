package vampire.quest.client.npctalk {

public interface Statement
{
    // can be null
    function createState () :Object;
    // returns the amount of time the update took, up to dt
    function update (dt :Number, state :Object) :Number;
    function isDone (state :Object) :Boolean;
}

}
