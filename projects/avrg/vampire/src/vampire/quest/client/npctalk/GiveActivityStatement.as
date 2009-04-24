package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class GiveActivityStatement
    implements Statement
{
    public function GiveActivityStatement (activity :ActivityDesc)
    {
        _activity = activity;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ClientCtx.questData.addAvailableActivity(_activity);
        return Status.CompletedInstantly;
    }

    protected var _activity :ActivityDesc;
}

}
