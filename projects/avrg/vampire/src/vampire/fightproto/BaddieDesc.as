package vampire.fightproto {

import com.whirled.contrib.simplegame.util.IntRange;
import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.client.SpriteUtil;

public class BaddieDesc
{
    public static const BABY_WEREWOLF :BaddieDesc = new BaddieDesc(
        "Baby Werewolf",
        "werewolf",
        0.3,
        10,
        new NumRange(3, 6, Rand.STREAM_GAME),
        [   new BaddieSkill(
                "Claw",
                "claw",
                new IntRange(1, 8, Rand.STREAM_GAME),
                Skill.NO_OUTPUT,
                1)
        ]);

    public static const MAMA_WEREWOLF :BaddieDesc = new BaddieDesc(
        "Mama Werewolf",
        "werewolf",
        0.5,
        20,
        new NumRange(5, 5, Rand.STREAM_GAME),
        [ new BaddieSkill(
            "Claw",
            "claw",
            new IntRange(5, 15, Rand.STREAM_GAME),
            Skill.NO_OUTPUT,
            1)
        ]);

    public static const DADDY_WEREWOLF :BaddieDesc = new BaddieDesc(
        "Daddy Werewolf",
        "werewolf",
        0.8,
        50,
        new NumRange(5, 8, Rand.STREAM_GAME),
        [   new BaddieSkill(
                "Claw",
                "claw",
                new IntRange(20, 25, Rand.STREAM_GAME),
                Skill.NO_OUTPUT,
                1),

            new BaddieSkill(
                "Heal",
                "heal",
                Skill.NO_OUTPUT,
                new IntRange(20, 25, Rand.STREAM_GAME),
                0.3),
        ]);

    public var displayName :String;
    public var imageName :String;
    public var imageScale :Number;
    public var health :Number;
    public var skillCastTime :NumRange;
    public var skills :Array = [];

    public function BaddieDesc (displayName :String, imageName :String, imageScale :Number,
        health :Number, skillCastTime :NumRange, skills :Array)
    {
        this.displayName = displayName;
        this.imageName = imageName;
        this.imageScale = imageScale;
        this.health = health;
        this.skillCastTime = skillCastTime;
        this.skills = skills;

        _totalSkillChance = 0;
        for each (var skill :BaddieSkill in this.skills) {
            _totalSkillChance += skill.castChance;
        }
    }

    public function chooseNextSkill () :BaddieSkill
    {
        if (skills.length == 0 || _totalSkillChance <= 0) {
            return null;
        }

        var rand :Number = Rand.nextNumberRange(0, _totalSkillChance, Rand.STREAM_GAME);
        var maxValue :Number = 0;
        for each (var skill :BaddieSkill in this.skills) {
            maxValue += skill.castChance;
            if (rand < maxValue) {
                return skill;
            }
        }

        // How did we get here?
        return skills[skills.length - 1];
    }

    public function createSprite () :Sprite
    {
        var sprite :Sprite = SpriteUtil.createSprite(false, true);

        var bitmap :Bitmap = ClientCtx.instantiateBitmap(imageName);
        bitmap.scaleX = bitmap.scaleY = imageScale;

        var tf :TextField = TextBits.createText(displayName, 1.2, 0, 0xff0000);

        var width :int = Math.max(tf.width, bitmap.width);

        tf.x = (width - tf.width) * 0.5;
        sprite.addChild(tf);

        bitmap.x = (width - bitmap.width) * 0.5;
        bitmap.y = tf.height;
        sprite.addChild(bitmap);

        return sprite;
    }

    protected var _totalSkillChance :Number;
}

}
