package vampire.quest.client.npctalk {

public class Routine
{
    public function Routine (name :String, statement :Statement = null)
    {
        _name = name;
        _statement = (statement != null ? statement : NoopStatement.INSTANCE);
    }

    public function get name () :String
    {
        return _name;
    }

    public function update (dt :Number) :Number
    {
        return _statement.update(dt);
    }

    public function get isDone () :Boolean
    {
        return _statement.isDone;
    }

    protected var _name :String;
    protected var _statement :Statement;
}

}
