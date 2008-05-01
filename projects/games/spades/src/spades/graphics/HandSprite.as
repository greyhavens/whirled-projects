package spades.graphics {

import com.whirled.contrib.card.Hand;
import com.whirled.contrib.card.graphics.HandSprite;

/** Spades hand object.
 *  TODO: this is a placeholder, refactor into Resources class */
public class HandSprite extends com.whirled.contrib.card.graphics.HandSprite
{
    /** Create a new hand. */
    public function HandSprite (hand :Hand)
    {
        super(hand, CardSpriteFactory.FACTORY);
    }
}

}
