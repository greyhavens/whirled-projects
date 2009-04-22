package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class HasQuestExpr
    implements Expr
{
    public static const EXISTS :int = 0;
    public static const IS_ACTIVE :int = 1;
    public static const IS_COMPLETE :int = 2;

    public function HasQuestExpr (quest :QuestDesc, exprType :int)
    {
        _quest = quest;
        _exprType = exprType;
    }

    public function eval () :*
    {
        var status :int = ClientCtx.questData.getQuestStatus(_quest.id);
        switch (_exprType) {
        case IS_ACTIVE:
            return status == PlayerQuestData.STATUS_ACTIVE;

        case IS_COMPLETE:
            return status == PlayerQuestData.STATUS_COMPLETE;

        case EXISTS:
            return status != PlayerQuestData.STATUS_NOT_ADDED;


        }
    }

    protected var _quest :QuestDesc;
    protected var _exprType :int;
}
}
