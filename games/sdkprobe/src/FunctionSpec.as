package {

public class FunctionSpec
{
    public function FunctionSpec (
        name :String, 
        func :Function,
        parameters :Array = null)
    {
        _func = func;
        _name = name;
        if (parameters == null) {
            _parameters = [];
        } else {
            _parameters = parameters.slice();
        }
    }

    public function get name () :String
    {
        return _name;
    }

    public function get func () :Function
    {
        return _func;
    }

    public function get parameters () :Array
    {
        return _parameters.slice();
    }

    protected var _func :Function;
    protected var _name :String;
    protected var _parameters :Array;
}

}
