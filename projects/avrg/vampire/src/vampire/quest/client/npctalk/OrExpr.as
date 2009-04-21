package vampire.quest.client.npctalk {

import com.threerings.util.ArrayUtil;

public class OrExpr
    implements Expr
{
    public function OrExpr (...exprs)
    {
        for each (var expr in exprs) {
            addExpr(expr);
        }
    }

    public function addExpr (expr :Expr) :void
    {
        _exprs.push(expr);
    }

    public function eval () :*
    {
        for each (var expr :Expr in _exprs) {
            if (Boolean(expr.eval()) {
                return true;
            }
        }

        return false;
    }

    protected var _exprs :Array = [];
}

}
