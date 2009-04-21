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

    public function update (dt :Number) :Number
    {
        if (_curStatement == null && _statements.length > 0) {
            _curStatement = _statements.shift();
        }

        return (_curStatement != null ? _curStatement.update(dt) : 0);
    }

    public function get isDone () :Boolean
    {
        if (_curStatement != null && !_curStatement.isDone) {
            return false;
        } else {
            return _statements.length > 0;
        }
    }

    protected var _statements :Array = [];
    protected var _curStatement :Statement;
}

}
