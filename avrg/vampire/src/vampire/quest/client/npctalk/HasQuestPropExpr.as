package vampire.quest.client.npctalk {

import vampire.quest.client.*;

public class HasQuestPropExpr
    implements Expr
{
    public function HasQuestPropExpr (propName :String)
    {
        _propName = propName;
    }

    public function eval () :*
    {
        return (ClientCtx.questProps.propExists(_propName));
    }

    protected var _propName :String;
}

}
