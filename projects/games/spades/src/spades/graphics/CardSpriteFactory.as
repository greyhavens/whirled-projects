package spades.graphics {

import com.whirled.contrib.card.Card;
import com.whirled.contrib.card.graphics.CardSprite;

/** Factory for spades card sprite.
 *  TODO: refactor into Resources */
public class CardSpriteFactory 
    implements com.whirled.contrib.card.graphics.CardSpriteFactory
{
    /** The static instance of the factory. */
    public static const FACTORY :CardSpriteFactory = new CardSpriteFactory();

    /** @inheritDoc */
    public function createCard (card :Card) :CardSprite {
        return new CardSprite(card, DECK, getCardWidth(), getCardHeight());
    }

    /** @inheritDoc */
    public function getCardWidth () :int {
        return 60;
    }

    /** @inheritDoc */
    public function getCardHeight () :int {
        return 80;
    }

    /** Embedded class containing card graphics */
    [Embed(source="../../../rsrc/deck.swf", mimeType="application/octet-stream")]
    protected static const DECK :Class;
}

}
