package vampire.quest.client.npctalk {

public class ResponseExpr
    implements Expr
{
    public function eval () :*
    {
        return ProgramCtx.lastResponseId;
    }
}

}
