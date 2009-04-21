package vampire.quest.client.npctalk {

public class StaticExpr
    implements Expr
{
    public function StaticExpr (val :*)
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
