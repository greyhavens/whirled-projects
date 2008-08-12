package {

public class ArrayParameter extends Parameter
{
    public function ArrayParameter (
        name :String, 
        type :Class, 
        flags :uint=0)
    {
        super(name, Array, flags);
        _underlying = type;
    }

    override public function get typeDisplay () :String
    {
        return "Array (" + _underlying + ")";
    }

    override public function parse (input :String) :Object
    {
        var temp :Parameter = new Parameter("", _underlying);
        var value :Array = [];
        var pos :int = 0;
        while (pos < input.length) {
            var comma :int = input.indexOf(",", pos);
            if (comma == -1) {
                comma = input.length;
            }
            value.push(temp.parse(input.slice(pos, comma)));
            pos = comma + 1;
        }
        return value;
    }

    protected var _underlying :Class;
}

}
