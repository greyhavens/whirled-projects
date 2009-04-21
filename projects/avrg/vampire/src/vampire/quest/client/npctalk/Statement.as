package vampire.quest.client.npctalk {

public interface Statement
{
    function begin () :void;
    function update (dt :Number) :void;
    function isDone () :Boolean;
}

}
