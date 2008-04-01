package spades.graphics {

import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.Debug;

import com.threerings.flash.Vector2;

/** Graphics for the cards in the trick. */
public class TrickSprite extends CardArraySprite
{
    /** Create a new trick sprite */
    public function TrickSprite (target :CardArray, numPlayers :int)
    {
        super(target);
        _numPlayers = numPlayers;
    }

    /** Set the seat (relative to local player) that is currently winning. The card in this slot 
     *  will be emphasized. */
    public function setWinner (seat :int) :void
    {
        var pos :int = (seat - _leader + _numPlayers) % _numPlayers;
        winningCard = pos;
    }

    /** Access the underlying trick. */
    public function get target () :CardArray
    {
        return _target;
    }

    /** Set the seat (relative to local player) that is leading this round. This means that when 
     *  the first card is played, it will appear in front of this seat. For example, a leader of 1
     *  will cause trick card 0 to show up in front of the seat to the left of the local player. */
    public function set leader (seat :int) :void
    {
        _leader = seat;
        Debug.debug("TrickSprite leader is " + _leader);
    }

    /** Access the leader of the current round. */
    public function get leader () :int
    {
        return _leader;
    }

    /** Set the card that is currently winning, relative to the first card played this round. */
    public function set winningCard (card :int) :void
    {
        if (_winningCard != card) {
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
    }

    /** Access the card that is currently winning, relative to the first card played this round. */
    public function get winningCard () :int
    {
        return _winningCard;
    }

    override protected function cardArrayListener (event :CardArrayEvent) :void
    {
        super.cardArrayListener(event);

        if (event.action == CardArrayEvent.ACTION_RESET) {
            // make sure new trick does not inherit previous winning card
            winningCard = -1;
        }
    }

    override protected function getStaticCardPosition (index :int, pos :Vector2) :void
    {
        var posIdx :int = (index + _leader) % CARD_POSITIONS.length;
        var staticPos :Vector2 = CARD_POSITIONS[posIdx] as Vector2;
        pos.x = staticPos.x;
        pos.y = staticPos.y;
    }

    protected var _numPlayers :int;
    protected var _leader :int;
    protected var _winningCard :int = -1;

    // layout in a cross
    protected static const CARD_POSITIONS :Array = [
        new Vector2(0, CardSprite.HEIGHT / 2),
        new Vector2(-CardSprite.WIDTH / 2, 0),
        new Vector2(0, -CardSprite.HEIGHT / 2),
        new Vector2(CardSprite.WIDTH / 2, 0)];
}

}

