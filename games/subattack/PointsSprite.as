package {

import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFormat;

import caurina.transitions.Tweener;

public class PointsSprite extends Sprite
{
    public function PointsSprite (points :int, xx :int, yy :int, seaDisplay :SeaDisplay)
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

        seaDisplay.addChild(this);

        Tweener.addTween(this, {
            y: this.y - 15,
            time: 1,
            transition: "linear",
            onComplete: seaDisplay.removeChild,
            onCompleteParams: [ this ]
        });
    }

    protected static const POSITIVE :TextFormat = new TextFormat("_sans", 12, 0xFFE21E, true);
    protected static const NEGATIVE :TextFormat = new TextFormat("_sans", 12, 0xFF0066, true);
}
}
