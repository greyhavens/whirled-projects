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
     * Add a card to the hand and rearrange cards
     * TODO make public? There are too many addCards(new Array(card)) around.
     */
    protected function addCard (card :Card, insertIndex :int = -1) :void
    {
        if (!contains(card)) {
            addChild(card);
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
     * Add each card present in the array to this container, then update the display
     * and synchronize the distributed data.  If insertIndex is provided, add them to a specific
     * point in the array.
     * TODO test insertIndex for multiple cards
     */
    public function addCards (cardArray :Array, insertIndex :int = -1) :void
    {
        if (cardArray == null) {
            _ctx.log("WTF card array null in addCards");
            return;
        }
        if (insertIndex < 0 || insertIndex > cards.length) {
            insertIndex = cards.length;
        }
        for (var i :int = 0; i < cardArray.length; i++) {
            var card :Card = cardArray[i];
            addCard(card, insertIndex + i);
        }
        updateDisplay();
        setDistributedData();
    }
    
    /**
     * Get the index of the card at the given global cooridnates, or -1 for none
     */
    public function getCardIndexByPoint (point :Point) :int
    {
        return -1;
    }
    
    /**
     * Remove a card and rearrange the display
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
     * Remove each card present in the array from this container, then update the display
     * and synchronize the distributed data.
     */
    public function removeCards (cardArray :Array) :void
    {
        if (cardArray == null) {
            _ctx.log("WTF card array null in removeCards");
            return;
        }
        for (var i :int = 0; i < cardArray.length; i++) {
            var card :Card = cardArray[i];
            removeCard(card);
        }
        updateDisplay();
        setDistributedData();
    }
    
    /**
     * Abstract method for setting distributed data.  Called after adding/removing cards.
     */
    public function setDistributedData () :void
    {
        // do nothing
    }
    
    /**
     * Abstract method for visually shifting cards around a global point when a card is dragged 
     * over them.
     */
    public function shiftCards (point :Point) :void
    {
        // do nothing
    }
    
    /**
     * Serialize a set of cards for distributing to other players
     */
    public function getSerializedCards () :Object
    {
        return cardIds;
    }
    
    /**
     * Set cards from a serialized list from other players
     * TODO make this MUCH more efficient
     */
    public function setSerializedCards (serializedCards :Object) :void
    {
        if (serializedCards == null) {
            _ctx.log("WTF serialized cards are null!");
            return;
        }
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
    
    /** Card objects in the container */
    protected var cards :Array = new Array();
    
    /** Card ids in the container */
    protected var cardIds :Array = new Array();
    
    /** distance between the left edges of cards */
    protected static const CARD_SPACING_X :int = 45;
}
}