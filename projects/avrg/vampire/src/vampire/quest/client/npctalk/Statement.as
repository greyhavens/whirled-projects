package vampire.quest.client.npctalk {

public interface Statement
{
    // can be null
    function createState () :Object;
    // returns a value from Status
    function update (dt :Number, state :Object) :Number;
}

}
