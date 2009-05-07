package vampire.fightproto {

import com.threerings.util.Log;
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

    public var name :String;
    public var imageName :String;
    public var damageOutput :IntRange;
    public var healOutput :IntRange;

    public function Skill (name :String, imageName :String, damageOutput :IntRange,
        healOutput :IntRange)
    {
        this.name = name;
        this.imageName = imageName;
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
        if (bitmap != null) {
            bitmap.scaleX = size.x / bitmap.width;
            bitmap.scaleY = size.y / bitmap.height;
            sprite.addChild(bitmap);

        } else {
            log.warning("Couldn't create bitmap for skill",
                "skillName", name, "imageName", imageName);
        }

        if (withText) {
            var tf :TextField = TextBits.createText(name, 1.1, 0, 0xffffff);
            tf.x = 2;
            tf.y = 2;
            sprite.addChild(tf);
        }

        return sprite;
    }

    public function get isDamageSkill () :Boolean
    {
        return damageOutput.max > 1;
    }

    public function get isHealSkill () :Boolean
    {
        return healOutput.max > 1;
    }

    protected static const BITMAP_SIZE :Point = new Point(50, 50);

    protected static var log :Log = Log.getLog(Skill);
}

}
