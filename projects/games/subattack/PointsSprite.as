package {

import flash.text.TextField;
import flash.text.TextFormat;

import com.threerings.flash.FrameSprite

public class PointsSprite extends FrameSprite
{
    public function PointsSprite (points :int)
    {
        _tf = new TextField();
        _tf.text = ((points > 0) ? "+" : "") + points;
        _tf.setTextFormat((points >= 0) ? POSITIVE : NEGATIVE);
        _tf.width = _tf.textWidth + 5;
        _tf.height = _tf.textHeight + 4;
        _tf.x = (SeaDisplay.TILE_SIZE - _tf.width) / 2;
        _tf.y = -_tf.height;
        addChild(_tf);
    }

    override protected function handleFrame (... ignored) :void
    {
        _tf.y -= .4;

        if (++_frames == 30) {
            this.parent.removeChild(this);
        }
    }

    protected var _tf :TextField;

    protected var _frames :int = 0;

    protected static const POSITIVE :TextFormat = new TextFormat("_sans", 12, 0xFFE21E, true);
    protected static const NEGATIVE :TextFormat = new TextFormat("_sans", 12, 0xFF0066, true);
}
}
