package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class HasLocationExpr
    implements Expr
{
    public function HasLocationExpr (loc :LocationDesc)
    {
        _loc = loc;
    }

    public function eval () :*
    {
        return ClientCtx.questData.isAvailableLocation(_loc);
    }

    protected var _loc :LocationDesc;
}
}
