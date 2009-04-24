package vampire.quest.activity {

import vampire.quest.activity.ActivityParams;

public class BloodBloomActivityParams extends ActivityParams
{
    public var preyName :String;

    public var awardedPropName :String;
    public var awardedPropIncrement :int;

    public function BloodBloomActivityParams (minPlayers :int, maxPlayers :int, preyName :String,
        awardedPropName :String, awardedPropIncrement :int)
    {
        super(minPlayers, maxPlayers);

        this.preyName = preyName;
        this.awardedPropName = awardedPropName;
        this.awardedPropIncrement = awardedPropIncrement;
    }
}

}
