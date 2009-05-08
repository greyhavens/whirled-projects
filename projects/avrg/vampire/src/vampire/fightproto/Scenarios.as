package vampire.fightproto {

import com.threerings.util.HashMap;

public class Scenarios
{
    public static function init () :void
    {
       addScenario(new Scenario(
            "intro",
            "Intro",
            0,
            10,
            [ "babykiller", "trouble" ],
            [ PlayerSkill.HEAL_1 ],
            [ BaddieDesc.BABY_WEREWOLF ],
            0));

        addScenario(new Scenario(
            "babykiller",
            "Babykiller",
            0,
            50,
            [],
            [ PlayerSkill.BITE_2 ],
            [ BaddieDesc.BABY_WEREWOLF, BaddieDesc.BABY_WEREWOLF, BaddieDesc.BABY_WEREWOLF ],
            0));

        addScenario(new Scenario(
            "trouble",
            "Trouble",
            2,
            100,
            [ "showdown" ],
            [ PlayerSkill.HEAL_2 ],
            [ BaddieDesc.MAMA_WEREWOLF, BaddieDesc.BABY_WEREWOLF, BaddieDesc.BABY_WEREWOLF ],
            0));

        addScenario(new Scenario(
            "showdown",
            "Showdown",
            3,
            500,
            [ "group" ],
            [ ],
            [ BaddieDesc.MAMA_WEREWOLF, BaddieDesc.DADDY_WEREWOLF ],
            0));

        addScenario(new Scenario(
            "group",
            "Boss Beatdown (Group)",
            3,
            1000,
            [],
            [ ],
            [ BaddieDesc.DADDY_WEREWOLF, BaddieDesc.KING_WEREWOLF ],
            1));
    }

    public static function getScenario (name :String) :Scenario
    {
        return _map.get(name) as Scenario;
    }

    protected static function addScenario (scenario :Scenario) :void
    {
        _map.put(scenario.name, scenario);
    }

    protected static var _map :HashMap = new HashMap();
}

}
