package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class SetVarStatement
    implements Statement
{
    public function SetVarStatement (name :String, valExpr :Expr)
    {
        _name = name;
        _valExpr = valExpr;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ProgramCtx.program.setVariable(_name, _valExpr.eval());
        return Status.CompletedInstantly;
    }

    protected var _name :String;
    protected var _valExpr :Expr;
}

}
