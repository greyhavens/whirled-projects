package vampire.quest.activity {

import vampire.quest.activity.ActivityParams;

public class CorruptionActivityParams extends BloodBloomActivityParams
{
    public var corruptionBlood :int;

    public function CorruptionActivityParams (minPlayers :int, maxPlayers :int, preyName :String,
        awardedPropName :String, awardedPropIncrement :int, corruptionBlood :int)
    {
        super(minPlayers, maxPlayers, preyName, awardedPropName, awardedPropIncrement);
        this.corruptionBlood = corruptionBlood;
    }
}

}
