package {

public class CallbackParameter extends Parameter
{
    public function CallbackParameter (name :String, flags :uint=0)
    {
        super(name, Function, flags);
    }

    override public function get typeDisplay () :String
    {
        return "Function";
    }

    override public function parse (input :String) :Object
    {
        throw new Error("Callbacks not parsed");
    }
}

}
