package vampire.quest.client.npctalk {

public class SayStatement
    implements Statement
{
    public function SayStatement (speakerName :String, text :String)
    {
        _speakerName = speakerName;
        _text = text;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ProgramCtx.view.say(_speakerName, _text);
        return Status.CompletedInstantly;
    }

    protected var _speakerName :String;
    protected var _text :String;
}
}
