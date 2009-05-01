package vampire.quest.client.npctalk {

import vampire.quest.*;
import vampire.quest.client.*;

public class GiveQuestStatement
    implements Statement
{
    public function GiveQuestStatement (quest :QuestDesc)
    {
        _quest = quest;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ClientCtx.questData.addQuest(_quest);
        return Status.CompletedInstantly;
    }

    protected var _quest :QuestDesc;
}

}
