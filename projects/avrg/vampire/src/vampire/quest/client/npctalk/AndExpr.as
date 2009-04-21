package vampire.quest.client.npctalk {

public class AndExpr
    implements Expr
{
    public function addExpr (expr :Expr) :void
    {
        _exprs.push(expr);
    }

    public function eval () :*
    {
        for each (var expr :Expr in _exprs) {
            if (!Boolean(expr.eval())) {
                return false;
            }
        }

        return true;
    }

    protected var _exprs :Array = [];
}

}
