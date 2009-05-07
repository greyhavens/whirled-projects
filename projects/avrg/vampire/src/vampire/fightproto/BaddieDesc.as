package vampire.fightproto {

import com.whirled.contrib.simplegame.util.IntRange;
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
        new IntRange(5, 8, Rand.STREAM_GAME));

    public static const WEREWOLF :BaddieDesc = new BaddieDesc(
        "Werewolf",
        "werewolf",
        0.6,
        20,
        new IntRange(8, 11, Rand.STREAM_GAME));

    public static const MAMA_WEREWOLF :BaddieDesc = new BaddieDesc(
        "Mama Werewolf",
        "werewolf",
        1,
        40,
        new IntRange(16, 20, Rand.STREAM_GAME));

    public var displayName :String;
    public var imageName :String;
    public var imageScale :Number;
    public var health :int;
    public var attackPower :IntRange;

    public function BaddieDesc (displayName :String, imageName :String, imageScale :Number,
        health :int, attackPower :IntRange)
    {
        this.displayName = displayName;
        this.imageName = imageName;
        this.imageScale = imageScale;
        this.health = health;
        this.attackPower = attackPower;
    }

    public function createSprite () :Sprite
    {
        var sprite :Sprite = SpriteUtil.createSprite(false, true);

        var bitmap :Bitmap = ClientCtx.instantiateBitmap(imageName);
        bitmap.scaleX = bitmap.scaleY = imageScale;

        var tf :TextField = TextBits.createText(displayName, 1.2, 0, 0xffffff);

        var width :int = Math.max(tf.width, bitmap.width);

        tf.x = (width - tf.width) * 0.5;
        sprite.addChild(tf);

        bitmap.x = (width - bitmap.width) * 0.5;
        bitmap.y = tf.height;
        sprite.addChild(bitmap);

        return sprite;
    }
}

}
