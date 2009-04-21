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
        return (this.gotResponse ? 0 : dt);
    }

    public function isDone (state :Object) :Boolean
    {
        return this.gotResponse;
    }

    protected function get gotResponse () :Boolean
    {
        return (ProgramCtx.lastResponseId != null);
    }

    protected var _responses :Array = [];
    protected var _ids :Array = [];
}
}
