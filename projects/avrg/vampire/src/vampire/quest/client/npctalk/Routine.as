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

    public function createState () :Object
    {
        return _statement.createState();
    }

    public function update (dt :Number, state :Object) :Number
    {
        return _statement.update(dt, state);
    }

    public function isDone (state :Object) :Boolean
    {
        return _statement.isDone(state);
    }

    protected var _name :String;
    protected var _statement :Statement;
}

}
