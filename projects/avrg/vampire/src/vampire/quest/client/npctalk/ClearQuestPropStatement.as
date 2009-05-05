package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class ClearQuestPropStatement
    implements Statement
{
    public function ClearQuestPropStatement (propName :String)
    {
        _propName = propName;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ClientCtx.questProps.clearProp(_propName);
        return Status.CompletedInstantly;
    }

    protected var _propName :String;
}

}
