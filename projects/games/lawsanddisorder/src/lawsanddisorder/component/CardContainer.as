package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

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
        // always add physical card object to the front regardless of insertIndex
        addChild(card);
        
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
     * Serialize a set of cards for distributing to other players.  If cardList is not supplied,
     * use this card container's card list.
     */
    public function getSerializedCards (cardList :Array = null) :Object
    {
        if (cardList == null) {
            return cardIds;
        }
        else {
            var cardListIds :Array = new Array();
            for (var i :int = 0; i < cardList.length; i++) {
                cardListIds[i] = cardList[i].id;
            }
            return cardListIds;
        }
    }

    /**
     * Set cards from a serialized list from other players, then update the card display
     */
    public function setSerializedCards (serializedCards :Object, 
        distributeData :Boolean = false) :void
    {
        if (serializedCards == null) {
            _ctx.error("serializedCards is null in CardContainer.setSerializedCards");
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
        
        if (distributeData) {
            setDistributedData();
        }
    }

    /**
     * Return the card in the given position.
     */
    public function getCardAtPosition (index :int) :Card
    {
        if (index >= cards.length) {
            _ctx.error("tried to get card by id when length " + cards.length + " >= index " + index);
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
     * Return a subset of cards that includes only verbs, subjects, objects or when cards
     */
    public function getCardsByGroup (group :int) :Array
    {
        var cardSublist :Array = new Array();
        for each (var card :Card in cards) {
            if (card.group == group) {
                cardSublist.push(card);
            }
        }
        return cardSublist;
    }

    /**
     * Convert this object to a string for debugging.
     */
    override public function toString () :String
    {
        return "Container [" + cards.length + " cards]";
    }
    
    /**
     * Select a random card.  If group is supplied, card must be of that type.  Return null if
     * no appropriate card could be found.  -1 is Card.NO_GROUP
     */
    public function pickRandom (group :int = -1) :Card
    {
        var availableCards :Array = cards;
        if (group != Card.NO_GROUP) {
            availableCards = getCardsByGroup(group);
        }
        if (availableCards.length == 0) {
            return null;
        }
        var randomIndex :int = Math.round(Math.random() * (availableCards.length-1));
        var randomCard :Card = availableCards[randomIndex];
        return randomCard;
    }

    /** Card objects in the container */
    public var cards :Array = new Array();

    /** Card ids in the container */
    protected var cardIds :Array = new Array();
}
}