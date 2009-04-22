package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class GiveLocationStatement
    implements Statement
{
    public function GiveLocationStatement (loc :LocationDesc)
    {
        _loc = loc;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ClientCtx.questData.addAvailableLocation(_loc);
        return Status.CompletedInstantly;
    }

    protected var _loc :LocationDesc;
}

}
