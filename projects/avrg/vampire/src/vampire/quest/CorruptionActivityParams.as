package vampire.quest {

public class CorruptionActivityParams
{
    public var totalBlood :int;
    public var minPlayers :int;
    public var maxPlayers :int;

    public var awardedStatName :String;
    public var awardedStatIncrement :int;

    public function CorruptionActivityParams (totalBlood :int, minPlayers :int, maxPlayers :int,
        awardedStatName :String, awardedStatIncrement :int)
    {
        this.totalBlood = totalBlood;
        this.minPlayers = minPlayers;
        this.maxPlayers = maxPlayers;
        this.awardedStatName = awardedStatName;
        this.awardedStatIncrement = awardedStatIncrement;
    }
}

}
