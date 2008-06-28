package {

public class Parameter
{
    public function Parameter (
        name :String, 
        type :Class, 
        required :Boolean=true)
    {
        _name = name;
        _type = type;
        _optional = !required;
    }

    public function get name () :String
    {
        return _name;
    }
    
    public function get type () :Class
    {
        return _type;
    }

    public function get typeDisplay () :String
    {
        if (_type == String) {
            return "String";

        } else if (_type == int) {
            return "int";
        }

        return "" + _type;
    }

    public function parse (input :String) :Object
    {
        if (_type == String) {
            return input;

        } else if (_type == int) {
            return parseInt(input);
        }

        throw new Error("Parsing for parameter type " + type + 
            " not implemented");
    }

    public function get optional () :Boolean
    {
        return _optional;
    }

    protected var _name :String;
    protected var _type :Class;
    protected var _optional :Boolean;
}

}
