package vampire.fightproto {

import com.whirled.contrib.simplegame.util.IntRange;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import vampire.client.SpriteUtil;

public class Skill
{
    public static const NO_OUTPUT :IntRange = new IntRange(0, 1, Rand.STREAM_GAME);

    public static const BITE_1 :Skill = new Skill(
        "Bite 1",
        "bite",
        1,
        2,
        20,
        new IntRange(1, 3, Rand.STREAM_GAME),
        NO_OUTPUT);

    public static const BITE_2 :Skill = new Skill(
        "Bite 2",
        "bite",
        2,
        2,
        80,
        new IntRange(2, 5, Rand.STREAM_GAME),
        NO_OUTPUT);

    public static const HEAL_1 :Skill = new Skill(
        "Heal 1",
        "heal",
        1,
        3,
        40,
        NO_OUTPUT,
        new IntRange(2, 4, Rand.STREAM_GAME));

    public var name :String;
    public var imageName :String;
    public var level :int;
    public var cooldown :Number;
    public var energyCost :int;
    public var damageOutput :IntRange;
    public var healOutput :IntRange;

    public function Skill (name :String, imageName :String, level :int, cooldown :Number,
        energyCost :int, damageOutput :IntRange, healOutput :IntRange)
    {
        this.name = name;
        this.imageName = imageName;
        this.level = level;
        this.cooldown = cooldown;
        this.energyCost = energyCost;
        this.damageOutput = damageOutput;
        this.healOutput = healOutput;
    }

    public function createSprite (size :Point = null, withText :Boolean = true) :Sprite
    {
        if (size == null) {
            size = BITMAP_SIZE;
        }

        var sprite :Sprite = SpriteUtil.createSprite(false, true);

        var bitmap :Bitmap = ClientCtx.instantiateBitmap(imageName);
        bitmap.scaleX = size.x / bitmap.width;
        bitmap.scaleY = size.y / bitmap.height;
        sprite.addChild(bitmap);

        if (withText) {
            var tf :TextField = TextBits.createText(name, 1.1, 0, 0xffffff);
            tf.x = 2;
            tf.y = 2;
            sprite.addChild(tf);
        }

        return sprite;
    }

    protected static const BITMAP_SIZE :Point = new Point(50, 50);
}

}