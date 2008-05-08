package lawsanddisorder.component {

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.events.MouseEvent;

import lawsanddisorder.Context;

/**
 * Superclass for components that contain a list of cards
 */
public class CardContainer extends Component
{
    /**
     * Constructor
     */
    public function CardContainer (ctx :Context)
    {
        super(ctx);
    }

    /**
     * Add each card present in the array to this container, then update the display
     * and synchronize the distributed data.  If insertIndex is provided, add them to a specific
     * point in the array.
     * TODO setting insertIndex = cards.length when too big or small seems hacky but needed
     *      when creating a new law and inserting 3-5 cards at insertIndex -1. fix
     */
    public function addCards (cardArray :Array, distribute :Boolean = true, insertIndex :int = -1) :void
    {
        if (insertIndex < 0 || insertIndex > cards.length) {
            insertIndex = cards.length;
        }
        for (var i :int = 0; i < cardArray.length; i++) {
            var card :Card = cardArray[i];
            addCard(card, insertIndex + i);
        }
        if (distribute) {
            setDistributedData();
        }
        updateDisplay();
    }

    /**
     * Add a card to the hand, but do not set distributed data or update the display.
     */
    protected function addCard (card :Card, insertIndex :int = -1) :void
    {
        if (!contains(card)) {
            if (insertIndex == -1) {
                addChild(card);
            }
            else {
                if (numChildren < insertIndex) {
                    // TODO how does this happen and can it be prevented?
                    //_ctx.log("WTF Card insert at " + insertIndex + " with " + numChildren + " children.");
                    addChild(card);
                }
                else {
                    addChildAt(card, insertIndex + getStartingChildIndex());
                }
            }
        }
        else {
            _ctx.log("WTF already contains child card: " + card);
        }
        if (cards.indexOf(card) < 0) {
            if (insertIndex < 0 || insertIndex > cards.length) {
                insertIndex = cards.length;
            }
            cardIds.splice(insertIndex, 0, card.id);
            cards.splice(insertIndex, 0, card);
            card.cardContainer = this;
        }
    }

    /**
     * Get the index of the card at the given global cooridnates, or -1 for none
     */
    public function getCardIndexByPoint (point :Point) :int
    {
        return -1;
    }

    /**
     * Remove each card present in the array from this container, then update the display
     * and synchronize the distributed data.
     */
    public function removeCards (cardArray :Array, distribute :Boolean = true) :void
    {
        for (var i :int = 0; i < cardArray.length; i++) {
            var card :Card = cardArray[i];
            removeCard(card);
        }
        if (distribute) {
            setDistributedData();
        }
        updateDisplay();
    }

    /**
     * Remove a card, but do not set distributed data or update the display
     */
    protected function removeCard (card :Card) :void
    {
        if (contains(card)) {
            removeChild(card);
        }
        if (cards.indexOf(card) >= 0) {
            var index :int = cards.indexOf(card);
            cards.splice(index, 1);
            cardIds.splice(index, 1);
        }
    }

    /**
     * Remove all cards. Does not trigger a distributed data event or update display.
     */
    protected function clearCards () :void
    {
        while (cards.length > 0) {
            var card :Card = cards[0];
            removeCard(card);
        }
    }

    /**
     * Abstract method for telling other players about a change to the distributed data.
     * Called after adding/removing cards.
     */
    protected function setDistributedData () :void
    {
        // do nothing
    }

    /**
     * Abstract method for visually shifting cards.  If a (global) point is provided, shift
     * the cards around the point to make room for the card being dragged over them.
     */
    public function arrangeCards (point :Point = null) :void
    {
        // do nothing
    }

    /**
     * Serialize a set of cards for distributing to other players
     */
    public function getSerializedCards () :Object
    {
        return cardIds;
/*
        if (cardIds == null) {
            _ctx.log("WTF cardIds is null in CardContainer.getSerializedCards");
            return "";
        }
        if (cardIds.length == 0) {
_ctx.log("no cards in getSerializedCards");
            return "";
        }

        var serializedCards :String = cardIds[0];
        for (var i :int = 1; i < cardIds.length; i++) {
            serializedCards += "," + cardIds[i];
        }
_ctx.log("get serialized cards: " + serializedCards);
        return serializedCards;
*/
    }

    /**
     * Set cards from a serialized list from other players, then update the card display
     * TODO don't set serialized cards if this is the player who changed them
     * TODO inefficient but simple - fix?
     */
    public function setSerializedCards (serializedCards :Object) :void
    {
        if (serializedCards == null) {
            _ctx.log("WTF serializedCards is null in CardContainer.setSerializedCards");
            return;
        }
//_ctx.log("set serialized cards: " + (serializedCards as String));
//        var newCardIds :Array = serializedCards.split(",");
//_ctx.log("set serialized len: " + newCardIds.length);
/*
_ctx.log("\n\nSET serialized cards : " + serializedCards);
_ctx.log("old cardsids: " + cardIds);
_ctx.log("old cards: " + cards);

        var newCardIds :Array = serializedCards as Array;
        for (var i :int = 0; i < newCardIds.length; i++) {

            // add card to the end of the arrays
            if (i >= cardIds.length) {
                var addCard :Card = _ctx.board.deck.getCard(newCardIds[i]);
                cardIds.push(newCardIds[i]);
                cards.push(addCard);
                if (!contains(addCard)) {
                    addChild(addCard);
                }
                addCard.cardContainer = this;
            }

            // replace card at index i
            else if (cardIds[i] != newCardIds[i]) {
                var oldCard :Card = cards[i];
                var newCard :Card = _ctx.board.deck.getCard(newCardIds[i]);
                cardIds[i] = newCardIds[i];
                cards[i] = newCard;
                if (!contains(newCard)) {
                    addChild(newCard);
                }
                newCard.cardContainer = this;
                // remove old card as child only if array doesn't contain it anymore
                if (contains(oldCard) && cardIds.indexOf(oldCard.id) < 0) {
                    removeChild(oldCard);
                }
            }
        }

        // truncate the cards arrays if required
        if (cardIds.length > newCardIds.length) {
            _ctx.log("cardIds longer: " + cardIds.length + " than: " + newCardIds.length);
            for (var j :int = newCardIds.length; j < cardIds.length; j++) {

                var extraOldCard :Card = cards[j];
                _ctx.log("removing card : " + extraOldCard);
                if (contains(extraOldCard) && cardIds.indexOf(extraOldCard.id) < 0) {
                    _ctx.log("removing child extra old card");
                    removeChild(extraOldCard);
                }
            }
            cardIds.length = newCardIds.length;
            cards.length = newCardIds.length;
        }
        */

        // remove all cards then readd them
        // won't trigger redisplay or synchronize
        var oldLength :int = cards.length;
        for (var oldIndex :int = 0; oldIndex < oldLength; oldIndex++) {
            removeCard(cards[0]);
        }

        var newCardIds :Array = serializedCards as Array;
        for (var i :int = 0; i < newCardIds.length; i++) {
            var card :Card = _ctx.board.deck.getCard(newCardIds[i]);
            addCard(card);
        }

        updateDisplay();
    }

    /**
     * Return the card in the given position.
     */
    public function getCardAtPosition (index :int) :Card
    {
        if (index >= cards.length) {
            _ctx.log("WTF tried to get card by id when length " + cards.length + " >= index " + index);
            return null;
        }
        return cards[index];
    }

    /**
     * Return the index of the given card, or -1 as an error if not present.
     */
    public function indexOfCard (card :Card) :int
    {
           for (var i :int = 0; i < cards.length; i++) {
               if (cards[i] == card) {
                   return i;
               }
           }
           return -1;
    }

    /**
     * Return the number of cards in the container
     */
    public function get numCards () :int
    {
        return cards.length;
    }

    /**
     * Return true if the cards array contains at least one card of group verb.
     */
    public function containsVerb () :Boolean
    {
        for each (var card :Card in cards) {
            if (card.group == Card.VERB) {
                return true;
            }
        }
        return false;
    }

    /**
     * Return true if the cards array contains at least one card of group subject.
     */
    public function containsSubject () :Boolean
    {
        for each (var card :Card in cards) {
            if (card.group == Card.SUBJECT) {
                return true;
            }
        }
        return false;
    }

    /**
     * Convert this object to a string for debugging.
     */
    override public function toString () :String
    {
        return "Container [" + cards.length + " cards]";
    }

    /**
     * The cards will be added as children starting at this index
     * TODO fugly
     */
    protected function getStartingChildIndex () :int
    {
        return 0;
    }

    /** Card objects in the container */
    protected var cards :Array = new Array();

    /** Card ids in the container */
    protected var cardIds :Array = new Array();
}
}