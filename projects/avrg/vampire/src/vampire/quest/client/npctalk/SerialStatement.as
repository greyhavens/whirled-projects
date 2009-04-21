package vampire.quest.client.npctalk {

public class SerialStatement
    implements Statement
{
    public function addStatement (statement :Statement) :void
    {
        if (_hasBegun) {
            throw new Error("Already running");
        }

        _statements.push(statement);
    }

    public function begin () :void
    {
        if (_hasBegun) {
            throw new Error("Already running");
        }

        if (_statements.length == 0) {
            // ensure that _curStatement is never null
            _statements.push(NoopStatement.INSTANCE);
        }

        beginNext();
    }

    public function update (dt :Number) :void
    {
        _curStatement.update(dt);
        if (_curStatement.isDone()) {
            beginNext();
        }
    }

    public function isDone () :Boolean
    {
        if (!_hasBegun) {
            throw new Error("Not running");
        }

        return (_statements.length == 0 && _curStatement.isDone());
    }

    protected function beginNext () :void
    {
        while (_statements.length > 0 && _curStatement.isDone()) {
            _curStatement = _statements.shift();
            _curStatement.begin();
        }
    }

    protected var _statements :Array = [];
    protected var _curStatement :Statement;
    protected var _hasBegun :Boolean;
}

}
