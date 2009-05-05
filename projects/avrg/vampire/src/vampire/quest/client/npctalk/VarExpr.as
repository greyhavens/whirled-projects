package vampire.quest.client.npctalk {

import vampire.quest.client.*;

public class VarExpr
    implements Expr
{
    public function VarExpr (name :String)
    {
        _name = name;
    }

    public function eval () :*
    {
        return ProgramCtx.program.getVariable(_name);
    }

    protected var _name :String;
}

}
