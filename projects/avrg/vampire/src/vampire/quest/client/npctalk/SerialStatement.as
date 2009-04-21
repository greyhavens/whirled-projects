package vampire.quest.client.npctalk {

public class SerialStatement
    implements Statement
{
    public function addStatement (statement :Statement) :void
    {
        _statements.push(statement);
    }

    public function update (dt :Number) :Number
    {
        if (_curStatement == null && _statements.length > 0) {
            _curStatement = _statements.shift();
        }

        var time :Number = 0;
        if (_curStatement != null) {
            time = _curStatement.update(dt);
            if (_curStatement.isDone) {
                _curStatement = null;
            }
        }

        return time;
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
