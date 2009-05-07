package vampire.fightproto {

public class Scenario
{
    public static const ALL :Array = [
        new Scenario(
            "Intro",
            10,
            [],
            [ BaddieDesc.BABY_WEREWOLF ]),

        new Scenario(
            "Easy",
            50,
            [ PlayerSkill.BITE_2 ],
            [ BaddieDesc.BABY_WEREWOLF, BaddieDesc.BABY_WEREWOLF, BaddieDesc.BABY_WEREWOLF ]),
    ];

    public var displayName :String;
    public var xpAward :int;
    public var skillAwards :Array;
    public var baddies :Array;

    public function Scenario (displayName :String, xpAward :int, skillAwards :Array, baddies :Array)
    {
        this.displayName = displayName;
        this.xpAward = xpAward;
        this.skillAwards = skillAwards;
        this.baddies = baddies;
    }
}

}
