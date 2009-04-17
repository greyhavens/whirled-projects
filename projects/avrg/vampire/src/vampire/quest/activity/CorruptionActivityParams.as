package vampire.quest.activity {

import vampire.quest.activity.ActivityParams;

public class CorruptionActivityParams extends ActivityParams
{
    public var preyName :String;
    public var totalBlood :int;

    public var awardedStatName :String;
    public var awardedStatIncrement :int;

    public function CorruptionActivityParams (minPlayers :int, maxPlayers :int, preyName :String,
        totalBlood :int, awardedStatName :String, awardedStatIncrement :int)
    {
        super(minPlayers, maxPlayers);

        this.preyName = preyName;
        this.totalBlood = totalBlood;
        this.awardedStatName = awardedStatName;
        this.awardedStatIncrement = awardedStatIncrement;
    }
}

}
