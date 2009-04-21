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

        var time :Number = 0;
        if (blockState.cur != null) {
            time = blockState.cur.update(dt, blockState.curState);
            if (blockState.cur.isDone(blockState.curState)) {
                blockState.cur = null;
            }
        }

        return time;
    }

    public function isDone (state :Object) :Boolean
    {
        var blockState :BlockState = BlockState(state);

        if (blockState.cur != null && !blockState.cur.isDone(blockState.curState)) {
            return false;
        } else {
            return blockState.nextIdx < _statements.length;
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
