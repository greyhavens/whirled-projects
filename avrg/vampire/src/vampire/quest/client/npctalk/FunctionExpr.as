package vampire.quest.client.npctalk {

public class FunctionExpr
    implements Expr
{
    public function FunctionExpr (f :Function)
    {
        if (f.length > 0) {
            throw new Error("f must take 0 arguments");
        }

        _f = f;
    }

    public function eval () :*
    {
        return _f();
    }

    protected var _f :Function;
}

}
