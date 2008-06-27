package {

public class FunctionSpec
{
    public function FunctionSpec (name :String, func :Function)
    {
        _func = func;
        _name = name;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get func () :Function
    {
        return _func;
    }

    protected var _func :Function;
    protected var _name :String;
}

}
