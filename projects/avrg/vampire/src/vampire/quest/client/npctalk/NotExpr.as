package vampire.quest.client.npctalk {

public class NotExpr
    implements Expr
{
    public function NotExpr (expr :Expr)
    {
        _expr = expr;
    }

    public function eval () :*
    {
        return !(Boolean(_expr.eval()));
    }

    protected var _expr :Expr;
}

}
