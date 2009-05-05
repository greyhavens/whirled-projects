package vampire.quest.client.npctalk {

import vampire.quest.client.*;

public class OffsetJuiceStatement
    implements Statement
{
    public function OffsetJuiceStatement (juiceOffset :int)
    {
        _juiceOffset = juiceOffset;
    }

    public function createState () :Object
    {
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ClientCtx.questData.offsetQuestJuice(_juiceOffset);
        return Status.CompletedInstantly;
    }

    protected var _juiceOffset :int;
}
}
