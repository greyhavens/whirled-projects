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
        var deck :CardArray = new CardArray();
        for (var i :int = 0; i < Card.SUITS.length; ++i) {
            for (var j :int = 0; j < Card.RANKS.length; ++j) {
                deck.push(new Card(Card.SUITS[i], Card.RANKS[j]));
            }
        }
        return deck;
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
        dispatchEvent(new CardArrayEvent(CardArrayEvent.PRERESET));

        _cards.splice(0, _cards.length);
        _ordinals.splice(0, _ordinals.length);

        setOrdinals(ordinals);

        dispatchEvent(new CardArrayEvent(CardArrayEvent.RESET));
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
        push(Card.createCardFromOrdinal(ordinal));
    }

    /** Add a new card to the end. */
    public function push (card :Card) :void
    {
        _ordinals.push(card.ordinal);
        _cards.push(card);
        dispatchEvent(new CardArrayEvent(CardArrayEvent.ADDED, card, length - 1));
    }

    /** Insert a new card into the array. */
    public function insert (card :Card, index :int) :void
    {
        _ordinals.splice(index, 0, card.ordinal);
        _cards.splice(index, 0, card);
        dispatchEvent(new CardArrayEvent(CardArrayEvent.ADDED, card, index));
    }

    /** Test if a card (of the same value) is in the array */
    public function has (card :Card) :Boolean
    {
        return indexOf(card) >= 0;
    }

    /** Get the index of a card in the array, or -1 if not present. */
    public function indexOf (card :Card) :int
    {
        for (var i :int = 0; i < _cards.length; ++i) {
            if (_cards[i].equals(card)) {
                return i;
            }
        }
        return -1;
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
                dispatchEvent(new CardArrayEvent(CardArrayEvent.REMOVED, c, i));
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
    
    /** Sort the array in place for player's ease of use. Suits are the primary key and ranks 
     *  secondary.
     *  @param suits an Array of Card.SUIT_* constants indicating the desired order of suits
     *  @param ordering one of the Card.RANK_ORDER_* constants indicating how to order the ranks */
    public function standardSort (suits :Array, ordering :int) :void
    {
        dispatchEvent(new CardArrayEvent(CardArrayEvent.PRERESET));

        _cards.sort(cmpCards);

        // restore the ordinals
        _ordinals = _cards.map(getOrdinal);

        dispatchEvent(new CardArrayEvent(CardArrayEvent.RESET));

        function getOrdinal (c :Card, i :int, a :Array) :int {
            return c.ordinal;
        }

        function cmpSuits (a :int, b :int) :int {
            return suits.indexOf(a) - suits.indexOf(b);
        }

        function cmpCards (a :Card, b :Card) :int {
            if (a.suit != b.suit) {
                return cmpSuits(a.suit, b.suit);
            }
            return Card.compareRanks(a.rank, b.rank, ordering);
        }
    }

    /** Insert a card into the array such that sorting is maintained. The array must previously be 
     *  sorted with the same parameters.
     *  @param card the card to insert
     *  @param suits an Array of Card.SUIT_* constants indicating the desired order of suits
     *  @param ordering one of the Card.RANK_ORDER_* constants indicating how to order the ranks */
    public function sortedInsert (card :Card, suits :Array, ordering :int) :void
    {
        for (var i :int = 0; i < _cards.length; ++i) {
            var c :Card = _cards[i];
            if (cmpCards(c, card) > 0) {
                insert(card, i);
                return;
            }
        }

        function cmpSuits (a :int, b :int) :int {
            return suits.indexOf(a) - suits.indexOf(b);
        }

        function cmpCards (a :Card, b :Card) :int {
            if (a.suit != b.suit) {
                return cmpSuits(a.suit, b.suit);
            }
            return Card.compareRanks(a.rank, b.rank, ordering);
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
            _cards.push(Card.createCardFromOrdinal(ord));
        }
    }

    /** The ordinals. */
    protected var _ordinals :Array = new Array();

    /** The Card objects. */
    protected var _cards :Array = new Array();
}

}
