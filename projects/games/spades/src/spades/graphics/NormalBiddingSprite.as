package spades.graphics {

import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.graphics.NormalBiddingSprite;

/** Spades bidding sprite.
 *  TODO: this is a placeholder, refactor into Resources class */
public class NormalBiddingSprite extends com.whirled.contrib.card.graphics.NormalBiddingSprite
{
    /** Create a new bidding sprite. */
    public function NormalBiddingSprite (bids :Bids)
    {
        var buttonZeroName :String = "button_0";
        var labelColor :uint = 0x264C62;
        var labelBottom :int = -23;
        var fudgeOffset :int = -3;

        super(bids, MOVIE, buttonZeroName, labelColor, labelBottom, fudgeOffset);
    }

    [Embed(source="../../../rsrc/bidding_normal.swf", mimeType="application/octet-stream")]
    protected static const MOVIE :Class;

    protected static const NUM_BUTTONS :int = 14;
}

}
