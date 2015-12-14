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

    protected var _name :String;
    protected var _statement :Statement;
}

}
