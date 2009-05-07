package vampire.fightproto {

public class Scenario
{
    public static const ALL :Array = [
        new Scenario(
            "Intro",
            10,
            [ BaddieDesc.BABY_WEREWOLF ]),

        new Scenario(
            "Easy",
            50,
            [ BaddieDesc.BABY_WEREWOLF, BaddieDesc.BABY_WEREWOLF, BaddieDesc.BABY_WEREWOLF ]),
    ];

    public var displayName :String;
    public var xpAward :int;
    public var baddies :Array = [];

    public function Scenario (displayName :String, xpAward :int, baddies :Array)
    {
        this.displayName = displayName;
        this.xpAward = xpAward;
        this.baddies = baddies;
    }
}

}
