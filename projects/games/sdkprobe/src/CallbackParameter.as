package {

public class CallbackParameter extends Parameter
{
    public function CallbackParameter (name :String, required :Boolean=true)
    {
        super(name, Function, required);
    }

    override public function parse (input :String) :Object
    {
        throw new Error("Callbacks not parsed");
    }
}

}
