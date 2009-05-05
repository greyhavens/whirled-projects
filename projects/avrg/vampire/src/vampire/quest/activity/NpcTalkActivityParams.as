package vampire.quest.activity {

import vampire.quest.activity.ActivityParams;

public class NpcTalkActivityParams extends ActivityParams
{
    public var dialogName :String;
    public var awardedPropName :String;
    public var awardedPropIncrement :int;

    public function NpcTalkActivityParams (dialogName :String, awardedPropName :String = null,
        awardedPropIncrement :int = 0)
    {
        super(1, 1);
        this.dialogName = dialogName;
        this.awardedPropName = awardedPropName;
        this.awardedPropIncrement = awardedPropIncrement;
    }
}

}
