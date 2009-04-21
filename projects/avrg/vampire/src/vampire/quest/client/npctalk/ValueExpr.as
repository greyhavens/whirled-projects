package vampire.quest.client.npctalk {

public class ValueExpr
    implements Expr
{
    public function ValueExpr (val :*)
    {
        _val = val;
    }

    public function eval () :*
    {
        return _val;
    }

    protected var _val :*;
}

}
