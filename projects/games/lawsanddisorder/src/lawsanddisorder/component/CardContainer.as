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
    }
    
    /**
     * Set cards from a serialized list from other players, then update the card display
     * TODO don't set serialized cards if this is the player who changed them
     */
    public function setSerializedCards (serializedCards :Object) :void
    {
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
                if (contains(oldCard) && cardIds.indexOf(oldCard) >= 0) {
                    removeChild(oldCard);
                }
        	}
        }
        
        // truncate the cards arrays if required
        if (cardIds.length > serializedCards.length) {
        	cardIds.length = serializedCards.length;
        	cards.length = serializedCards.length;
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