package spades.graphics {

import spades.card.CardArray;

/** Graphics for the cards in the last trick. */
public class LastTrickSprite extends TrickSprite
{
    /** Create a new trick sprite */
    public function LastTrickSprite (numPlayers :int)
    {
        super(new CardArray(), numPlayers);
    }
}

}
