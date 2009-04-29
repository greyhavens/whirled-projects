package vampire.quest.client.npctalk {

public class AddResponseStatement
    implements Statement
{
    public function AddResponseStatement (id :String, text :String)
    {
        _id = id;
        _text = text;
    }

    public function createState () :Object
    {
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ProgramCtx.view.addResponse(_id, _text);
        return Status.CompletedInstantly;
    }

    protected var _id :String;
    protected var _text :String;
}

}
