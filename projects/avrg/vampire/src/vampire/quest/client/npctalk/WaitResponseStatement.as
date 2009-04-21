package vampire.quest.client.npctalk {

public class WaitResponseStatement
    implements Statement
{
    public function update (dt :Number) :Number
    {
        if (!_gotResponse) {
            _gotResponse = (ProgramCtx.lastResponseId != null);
        }

        return (_gotResponse ? 0 : dt);
    }

    public function get isDone () :Boolean
    {
        return _gotResponse;
    }

    protected var _responses :Array = [];
    protected var _ids :Array = [];

    protected var _gotResponse :Boolean;
}
}
