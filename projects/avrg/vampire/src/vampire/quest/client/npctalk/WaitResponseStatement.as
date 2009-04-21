package vampire.quest.client.npctalk {

public class WaitResponseStatement
    implements Statement
{
    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        return (ProgramCtx.lastResponseId != null ? Status.CompletedInstantly : Status.Incomplete);
    }

    protected var _responses :Array = [];
    protected var _ids :Array = [];
}
}
