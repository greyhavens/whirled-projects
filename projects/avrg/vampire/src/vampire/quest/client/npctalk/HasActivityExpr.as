package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class HasActivityExpr
    implements Expr
{
    public function HasActivityExpr (activity :ActivityDesc)
    {
        _activity = activity;
    }

    public function eval () :*
    {
        return ClientCtx.questData.isActivityUnlocked(_activity);
    }

    protected var _activity :ActivityDesc;
}
}
