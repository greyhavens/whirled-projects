package {

import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFormat;

import com.threerings.flash.path.Path;

public class PointsSprite extends Sprite
{
    public function PointsSprite (points :int, xx :int, yy :int)
    {
        var tf :TextField = new TextField();
        tf.text = ((points > 0) ? "+" : "") + points;
        tf.setTextFormat((points >= 0) ? POSITIVE : NEGATIVE);
        tf.width = tf.textWidth + 5;
        tf.height = tf.textHeight + 4;
        tf.x = (SeaDisplay.TILE_SIZE - tf.width) / 2;
        tf.y = -tf.height;
        addChild(tf);

        this.x = xx * SeaDisplay.TILE_SIZE;
        this.y = yy * SeaDisplay.TILE_SIZE;

        var path :Path = Path.moveTo(this, this.x, this.y - 12, 1000);
        path.setOnComplete(remove);
        path.start();
    }

    protected function remove (path :Path) :void
    {
        this.parent.removeChild(this);
    }

    protected static const POSITIVE :TextFormat = new TextFormat("_sans", 12, 0xFFE21E, true);
    protected static const NEGATIVE :TextFormat = new TextFormat("_sans", 12, 0xFF0066, true);
}
}
