package vampire.quest.client.npctalk {

public class BlockStatement
    implements Statement
{
    public function addStatement (statement :Statement, idx :int = -1) :void
    {
        if (idx >= 0 && idx < _statements.length) {
            _statements.splice(idx, 0, statement);
        } else {
            _statements.push(statement);
        }
    }

    public function createState () :Object
    {
        return new BlockState();
    }

    public function update (dt :Number, state :Object) :Number
    {
        var blockState :BlockState = BlockState(state);

        var totalTime :Number = 0;
        while (totalTime < dt && !ProgramCtx.program.hasInterrupt) {
            if (blockState.cur == null && blockState.nextIdx < _statements.length) {
                blockState.cur = _statements[blockState.nextIdx++];
                blockState.curState = blockState.cur.createState();
            }

            if (blockState.cur == null) {
                return Status.CompletedAfter(totalTime);

            } else {
                var curStatus :Number = blockState.cur.update(dt, blockState.curState);
                if (Status.isComplete(curStatus)) {
                    totalTime += curStatus;
                    blockState.cur = null;

                } else {
                    return Status.Incomplete;
                }
            }
        }

        return Status.Incomplete;
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
