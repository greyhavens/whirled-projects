package vampire.fightproto {

public class Scenario
{
    public var name :String;
    public var displayName :String;
    public var minPlayerLevel :int;
    public var xpAward :int;
    public var scenarioAwards :Array;
    public var skillAwards :Array;
    public var baddies :Array;

    public function Scenario (name :String, displayName :String, minPlayerLevel :int, xpAward :int,
        scenarioAwards :Array, skillAwards :Array, baddies :Array)
    {
        this.name = name;
        this.displayName = displayName;
        this.minPlayerLevel = minPlayerLevel;
        this.xpAward = xpAward;
        this.scenarioAwards = scenarioAwards;
        this.skillAwards = skillAwards;
        this.baddies = baddies;
    }
}

}
