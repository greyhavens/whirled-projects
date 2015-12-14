package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class SetQuestPropStatement
    implements Statement
{
    public function SetQuestPropStatement (propName :String, valExpr :Expr)
    {
        _propName = propName;
        _valExpr = valExpr;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ClientCtx.questProps.setProp(_propName, _valExpr.eval());
        return Status.CompletedInstantly;
    }

    protected var _propName :String;
    protected var _valExpr :Expr;
}

}
