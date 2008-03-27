package spades.card {

import flash.display.DisplayObject;
import flash.events.EventDispatcher;

/**
 * An ordered container of cards with event dispatching. Maintains consistency between an array of 
 * ordinals (integers) for use in serialization and an array of Card objects for rendering and game 
 * logic. Dispatches CardArrayEvent objects when changes occur. May be extended as needed for use in 
 * spades and other card games.
 */
public class CardArray extends EventDispatcher
{
    /** A full deck of cards. Users promise not to modify the deck. */
    public static const FULL_DECK :CardArray = makeDeck();

    /** Create a new full deck. Users may modify the result. */
    public static function makeDeck () :CardArray
    {
        var ordinals :Array = new Array(Card.NUM_ORDINALS);
        ordinals.forEach(assign);
        return new CardArray(ordinals);

        function assign (x :*, i :int, a :Array) :void
        {
            a[i] = i;
        }
    }
    
    /**
     * Create a new array of cards.
     * @param ordinals optional array of ordinal values for initial contents
     * @throws CardException if any contents are not valid.
     */
    public function CardArray (ordinals :Array=null)
    {
        setOrdinals(ordinals);
    }
    
    /** Reset the contents of the array.
     * @param ordinals optional array of ordinal values for the new contents
     * @throws CardException if any ordinals are not valid. */
    public function reset (ordinals :Array=null) :void
    {
        dispatchEvent(CardArrayEvent.preReset());

        _cards.splice(0, _cards.length);
        _ordinals.splice(0, _ordinals.length);

        setOrdinals(ordinals);

        dispatchEvent(CardArrayEvent.reset());
    }

    /** @inheritDoc */
    // from flash.events.EventDispatcher
    public override function addEventListener(
        type :String, 
        listener :Function, 
        useCapture :Boolean=false, 
        priority :int = 0, 
        useWeakReference :Boolean=false) :void
    {
        if (type != CardArrayEvent.CARD_ARRAY) {
            throw new Error("Adding listsner for invalid event type " + type);
        }
        return super.addEventListener(type, listener, useCapture, priority, 
            useWeakReference);
    }

    /** @inheritDoc */
    // from flash.events.EventDispatcher
    public override function removeEventListener(
        type :String, 
        listener :Function, 
        useCapture :Boolean=false) :void
    {
        if (type != CardArrayEvent.CARD_ARRAY) {
            throw new Error("Removing listsner for invalid event type " + type);
        }
        return super.removeEventListener(type, listener, useCapture);
    }

    /** Access the underlying array of ordinal values. */
    public function get ordinals () :Array
    {
        return _ordinals;
    }
    
    /** Access the underlying array of card objects. */
    public function get cards () :Array
    {
        return _cards;
    }

    /** Access to the length of the array. */
    public function get length () :int
    {
        return _ordinals.length;
    }
    
    /** Add a new card to the end by ordinal value. */
    public function pushOrdinal (ordinal :int) :void
    {
        push(Card.createCard(ordinal));
    }

    /** Add a new card to the end. */
    public function push (card :Card) :void
    {
        _ordinals.push(card.ordinal);
        _cards.push(card);
        dispatchEvent(CardArrayEvent.added(card, length - 1));
    }

    /** Test if a card (of the same value) is in the array */
    public function has (card :Card) :Boolean
    {
        return _cards.some(equal);

        function equal (c :Card, i :int, a :Array) :Boolean
        {
            return c.equals(card);
        }
    }

    /** Remove a card from the array. 
     *  @throws CardException if the card is not present. */
    public function remove (card :Card) :void
    {
        if (!_cards.some(doRemove)) {
            throw new CardException("Card " + card + " not found");
        }

        function doRemove (c :Card, i :int, a :Array) :Boolean
        {
            if (c.equals(card)) {
                _cards.splice(i, 1);
                _ordinals.splice(i, 1);
                dispatchEvent(CardArrayEvent.removed(c, i));
                return true;
            }
            return false;
        }
    }

    /** Returns a new CardArray consisting of the contents of this array for which the given 
     *  callback evaluates to true. The callback should have signature:
     *
     *     function callback (card :Card, index :int, array :CardArray) :Boolean
     *
     *  For example, the following function will return all queens:
     *
     *     function findQueens (array :CardArray) :CardArray
     *     {
     *         return array.filter(
     *             function (
     *                 card :Card, 
     *                 index :int, 
     *                 array :CardArray) :Boolean {
     *                 return card.rank == Card.QUEEN;
     *             });
     *     }
     *         
     */
    public function filter (callback :Function) :CardArray
    {
        var newArray :CardArray = new CardArray();
        _cards.forEach(pushIfTrue);
        return newArray;
        
        function pushIfTrue (c :Card, i :int, a :Array) :void
        {
            if (callback(c, i, this)) {
                newArray.push(c);
            }
        }
    }

    /** Returns a new CardArray consisting of the contents of this array for which the given 
     *  callback evaluates to true. The callback should have signature:
     *
     *     function callback (card :Card) :Boolean
     *
     *  This is a more terse alternative to the more standard-compliant "filter" method.
     *
     *  For example, the following function will return all queens:
     *
     *     function findQueens (array :CardArray) :CardArray
     *     {
     *         return array.filter(
     *             function (
     *                 card :Card) :Boolean {
     *                 return card.rank == Card.QUEEN;
     *             });
     *     }
     *         
     */
    public function shortFilter (callback :Function) :CardArray
    {
        var newArray :CardArray = new CardArray();
        _cards.forEach(pushIfTrue);
        return newArray;
        
        function pushIfTrue (c :Card, i :int, a :Array) :void
        {
            if (callback(c)) {
                newArray.push(c);
            }
        }
    }

    /** @inheritDoc */
    public override function toString () :String
    {
        var s :String = "";
        _cards.forEach(append);
        return s;

        function append (c :Card, i :int, a :Array) :void
        {
            if (i > 0) {
                s += ", ";
            }
            s += c.toString();
        }
    }

    /** Set the ordinal values, no event sending. */
    protected function setOrdinals (ordinals :Array) :void
    {
        if (ordinals != null) {
            ordinals.forEach(push);
        }

        function push (ord :int, i :int, a :Array) :void
        {
            _ordinals.push(ord);
            _cards.push(Card.createCard(ord));
        }
    }

    /** The ordinals. */
    protected var _ordinals :Array = new Array();

    /** The Card objects. */
    protected var _cards :Array = new Array();
}

}
