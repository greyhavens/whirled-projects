package vampire.quest.client.npctalk {

import vampire.quest.client.*;

public class QuestPropValExpr
    implements Expr
{
    public function QuestPropValExpr (propName :String)
    {
        _propName = propName;
    }

    public function eval () :*
    {
        return (ClientCtx.questProps.propExists(_propName) ?
            ClientCtx.questProps.getProp(_propName) : undefined);
    }

    protected var _propName :String;
}

}
