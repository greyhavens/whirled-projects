package spades.graphics {

import spades.card.Trick;
import spades.card.Table;
import spades.card.TrickEvent;
import spades.Debug;

import com.threerings.flash.Vector2;

/** Graphics for the cards in the trick. */
public class TrickSprite extends CardArraySprite
{
    /** Create a new trick sprite */
    public function TrickSprite (target :Trick, seating :Table)
    {
        super(target.cards, false);
        _trick = target;
        _seating = seating;

        positionCards();

        _trick.addEventListener(TrickEvent.FRONTRUNNER_CHANGED, trickListener);
        _trick.addEventListener(TrickEvent.RESET, trickListener);
    }

    /** Set the card that is currently winning, relative to the first card played this round. */
    protected function set winningCard (card :int) :void
    {
        _winningCard = card;
        for (var i :int = 0; i < _cards.length; ++i) {
            var c :CardSprite = _cards[i];
            if (i == _winningCard) {
                c.state = CardSprite.EMPHASIZED;
            }
            else {
                c.state = CardSprite.NORMAL;
            }
        }
    }

    /** Access the card that is currently winning, relative to the first card played this round. */
    protected function get winningCard () :int
    {
        return _winningCard;
    }

    protected function trickListener (event :TrickEvent) :void
    {
        if (event.type == TrickEvent.RESET) {
            winningCard = -1;
        }
        else if (event.type == TrickEvent.FRONTRUNNER_CHANGED) {
            winningCard = _trick.cards.indexOf(event.card);
        }
    }

    override protected function getStaticCardPosition (index :int, pos :Vector2) :void
    {
        var leader :int = _seating.getRelativeFromId(_trick.leader);
        var posIdx :int = _seating.getSeatAlong(leader, index);
        var staticPos :Vector2 = CARD_POSITIONS[posIdx] as Vector2;
        pos.x = staticPos.x;
        pos.y = staticPos.y;
    }

    protected var _trick :Trick;
    protected var _winningCard :int = -1;
    protected var _seating :Table;

    // layout in a cross
    protected static const CARD_POSITIONS :Array = [
        new Vector2(0, CardSprite.HEIGHT / 2),
        new Vector2(-CardSprite.WIDTH / 2, 0),
        new Vector2(0, -CardSprite.HEIGHT / 2),
        new Vector2(CardSprite.WIDTH / 2, 0)];
}

}

