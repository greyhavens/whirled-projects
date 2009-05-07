package vampire.fightproto {

import com.whirled.contrib.simplegame.util.IntRange;

public class BaddieSkill extends Skill
{
    public var castChance :Number;

    public function BaddieSkill (name :String, imageName :String, damageOutput :IntRange,
        healOutput :IntRange, castChance :Number)
    {
        super(name, imageName, damageOutput, healOutput);
        this.castChance = castChance;
    }

}

}
