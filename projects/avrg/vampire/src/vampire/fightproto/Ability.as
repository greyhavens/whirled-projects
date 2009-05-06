package vampire.fightproto {

import com.whirled.contrib.simplegame.util.IntRange;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import vampire.client.SpriteUtil;

public class Ability
{
    public static const NO_OUTPUT :IntRange = new IntRange(0, 0, Rand.STREAM_GAME);

    public static const BITE_1 :Ability = new Ability(
        "Bite 1",
        "bite",
        1,
        1,
        new IntRange(1, 3, Rand.STREAM_GAME),
        NO_OUTPUT);

    public static const BITE_2 :Ability = new Ability(
        "Bite 2",
        "bite",
        2,
        2,
        new IntRange(2, 5, Rand.STREAM_GAME),
        NO_OUTPUT);

    public var displayName :String;
    public var imageName :String;
    public var level :int;
    public var energyCost :int;
    public var damageOutput :IntRange;
    public var healOutput :IntRange;

    public function Ability (displayName :String, imageName :String, level :int, energyCost :int,
        damageOutput :IntRange, healOutput :IntRange)
    {
        this.displayName = displayName;
        this.imageName = imageName;
        this.level = level;
        this.energyCost = energyCost;
        this.damageOutput = damageOutput;
        this.healOutput = healOutput;
    }

    public function createSprite () :Sprite
    {
        var sprite :Sprite = SpriteUtil.createSprite(false, true);

        var bitmap :Bitmap = ClientCtx.instantiateBitmap(imageName);
        bitmap.scaleX = BITMAP_SIZE.x / bitmap.width;
        bitmap.scaleY = BITMAP_SIZE.y / bitmap.height;
        sprite.addChild(bitmap);

        var tf :TextField = TextBits.createText(displayName, 1.1, 0, 0xffffff);
        tf.x = 2;
        tf.y = 2;
        sprite.addChild(tf);

        return sprite;
    }

    protected static const BITMAP_SIZE :Point = new Point(50, 50);
}

}
