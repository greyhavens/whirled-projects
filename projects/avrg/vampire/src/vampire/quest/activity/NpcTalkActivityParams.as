package vampire.quest.activity {

import vampire.quest.activity.ActivityParams;

public class NpcTalkActivityParams extends ActivityParams
{
    public var dialogName :String;

    public function NpcTalkActivityParams (dialogName :String)
    {
        super(1, 1);
        this.dialogName = dialogName;
    }
}

}
