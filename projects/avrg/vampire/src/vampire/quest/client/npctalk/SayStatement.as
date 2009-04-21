package vampire.quest.client.npctalk {

public class SayStatement
    implements Statement
{
    public function SayStatement (speakerName :String, text :String)
    {
        _speakerName = speakerName;
        _text = text;
    }

    public function update (dt :Number) :Number
    {
        ProgramCtx.view.say(_speakerName, _text);
    }

    public function get isDone () :Boolean
    {
        return true;
    }

    protected var _speakerName :String;
    protected var _text :String;
}
}
