package vampire.quest.activity {

import vampire.quest.activity.ActivityParams;

public class CorruptionActivityParams extends BloodBloomActivityParams
{
    public var corruptionBlood :int;

    public function CorruptionActivityParams (minPlayers :int, maxPlayers :int, preyName :String,
        awardedStatName :String, awardedStatIncrement :int, corruptionBlood :int)
    {
        super(minPlayers, maxPlayers, preyName, awardedStatName, awardedStatIncrement);
        this.corruptionBlood = corruptionBlood;
    }
}

}
