package vampire.quest.client.npctalk {

public class BlockStatement
    implements Statement
{
    public function addStatement (statement :Statement) :void
    {
        _statements.push(statement);
    }

    public function createState () :Object
    {
        return new BlockState();
    }

    public function update (dt :Number, state :Object) :Number
    {
        var blockState :BlockState = BlockState(state);

        if (blockState.cur == null && blockState.nextIdx < _statements.length) {
            blockState.cur = _statements[blockState.nextIdx++];
            blockState.curState = blockState.cur.createState();
        }

        if (blockState.cur == null) {
            return Status.CompletedInstantly;

        } else {
            var curStatus :Number = blockState.cur.update(dt, blockState.curState);
            if (Status.isComplete(curStatus)) {
                blockState.cur = null;
                return (blockState.nextIdx >= _statements.length ? curStatus : Status.Incomplete);
            } else {
                return Status.Incomplete;
            }
        }
    }

    protected var _statements :Array = [];
}

}

import vampire.quest.client.npctalk.Statement;

class BlockState
{
    public var nextIdx :int;
    public var cur :Statement;
    public var curState :Object;
}
