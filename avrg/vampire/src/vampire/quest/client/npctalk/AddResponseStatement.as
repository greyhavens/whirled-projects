package vampire.quest.client.npctalk {

public class AddResponseStatement
    implements Statement
{
    public function AddResponseStatement (id :String, text :String, juiceCost :int)
    {
        _id = id;
        _text = text;
        _juiceCost = juiceCost;
    }

    public function createState () :Object
    {
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ProgramCtx.view.addResponse(_id, _text, _juiceCost);
        return Status.CompletedInstantly;
    }

    protected var _id :String;
    protected var _text :String;
    protected var _juiceCost :int;
}

}
