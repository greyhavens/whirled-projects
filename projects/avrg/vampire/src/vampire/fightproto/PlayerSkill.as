package vampire.fightproto {

import com.whirled.contrib.simplegame.util.IntRange;
import com.whirled.contrib.simplegame.util.Rand;

public class PlayerSkill extends Skill
{
    public static const BITE_1 :Skill = new PlayerSkill(
        "Bite 1",
        "bite",
        new IntRange(1, 3, Rand.STREAM_GAME),
        NO_OUTPUT,
        1,
        2,
        20);

    public static const BITE_2 :Skill = new PlayerSkill(
        "Bite 2",
        "bite",
        new IntRange(2, 5, Rand.STREAM_GAME),
        NO_OUTPUT,
        2,
        2,
        80);

    public static const HEAL_1 :Skill = new PlayerSkill(
        "Heal 1",
        "heal",
        NO_OUTPUT,
        new IntRange(2, 4, Rand.STREAM_GAME),
        1,
        3,
        40);

    public var level :int;
    public var cooldown :Number;
    public var energyCost :int;

    public function PlayerSkill (name :String, imageName :String, damageOutput :IntRange,
        healOutput :IntRange, level :int, cooldown :Number, energyCost :int)
    {
        super(name, imageName, damageOutput, healOutput);

        this.level = level;
        this.cooldown = cooldown;
        this.energyCost = energyCost;
    }

}

}
