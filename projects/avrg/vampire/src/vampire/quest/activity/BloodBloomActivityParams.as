package vampire.quest.activity {

import vampire.quest.activity.ActivityParams;

public class BloodBloomActivityParams extends ActivityParams
{
    public var preyName :String;

    public var awardedStatName :String;
    public var awardedStatIncrement :int;

    public function BloodBloomActivityParams (minPlayers :int, maxPlayers :int, preyName :String,
        awardedStatName :String, awardedStatIncrement :int)
    {
        super(minPlayers, maxPlayers);

        this.preyName = preyName;
        this.awardedStatName = awardedStatName;
        this.awardedStatIncrement = awardedStatIncrement;
    }
}

}
