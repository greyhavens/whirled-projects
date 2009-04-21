package vampire.quest.client.npctalk {

public class SayStatement
    implements Statement
{
    public function SayStatement (speakerName :String, text :String)
    {
        _speakerName = speakerName;
        _text = text;
    }

    public function addResponse (text :String, id :String) :void
    {
        _responses.push(text);
        _ids.push(id);
    }

    public function update (dt :Number) :Number
    {
        ProgramCtx.view.say(_speakerName, _text);
        ProgramCtx.view.setResponses(_responses, _ids);
        return 0;
    }

    public function get isDone () :Boolean
    {
        return true;
    }

    protected var _speakerName :String;
    protected var _text :String;
    protected var _responses :Array = [];
    protected var _ids :Array = [];
}
}
