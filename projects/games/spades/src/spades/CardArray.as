package spades {

import flash.display.DisplayObject;
import com.threerings.util.Log;

/**
 * An ordered container of cards with an optional display component. Maintains consistency between 
 * an array of ordinals (integers) for use in serialization and an array of Card objects for 
 * rendering and game logic. The class may be extended as needed for use in spades and other card 
 * games.
 */
public class CardArray
{
    /** A full deck of cards. Users promise not to modify the deck. */
    public static const FULL_DECK :CardArray = makeDeck();

    /** Create a new full deck. Users may modify the result. */
    public static function makeDeck () :CardArray
    {
        var ordinals :Array = new Array(Card.NUM_ORDINALS);
        for (var i :int = 0; i < ordinals.length; ++i) {
            ordinals[i] = i;
        }

        return new CardArray(ordinals);
    }
    
    /**
     * Create a new container.
     * @param ordinals optional array or ordinal values for initial contents
     * @throws CardException if any contents are not valid.
     */
    public function CardArray (ordinals :Array=null)
    {
        if (ordinals != null) {
            for (var i :int = 0; i < ordinals.length; ++i) {
                if (!(ordinals[i] is int)) {
                    throw new CardException(
                        "Expected integral array, " + 
                        ordinals[i] + " is not integral");
                }
                
                pushOrdinal(ordinals[i] as int);
            }
        }
    }

    /** Access the object to display the container. Created on demand. */
    public function get display () :DisplayObject
    {
        if (_display == null) {
            _display = new CardArraySprite(this, onClick);
        }

        return _display;
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
        pushCard(Card.createCard(ordinal));
    }

    /** Add a new card to the end. */
    public function pushCard (card :Card) :void
    {
        _ordinals.push(card.ordinal);
        _cards.push(card);
        if (_display != null) {
            _display.addChild(card.display);
        }
    }

    /** Test if a card (of the same value) is in the array */
    public function has (card :Card) :Boolean
    {
        for (var i :int = 0; i < _cards.length; ++i) {
            if (_cards[i].equals(card)) {
                return true;
            }
        }
        return false;
    }

    /** Remove a card from the array. 
     *  @throws CardException if the card is not present. */
    public function remove (card :Card) :void
    {
        for (var i :int = 0; i < _cards.length; ++i) {
            if (_cards[i].equals(card)) {
                _display.removeChild(_cards[i].display);
                _cards.splice(i, 1);
                _ordinals.splice(i, 1);
                return;
            }
        }

        throw new CardException("Card " + card + " not found");
    }

    /** Disable clicking on all cards. */
    public function disable () :void
    {
        if (_display == null) {
            return;
        }

        for (var i :int = 0; i < _cards.length; ++i) {
            _cards[i].enabled = false;
        }
    }
    
    /** Enable clicking on all cards. When a card is clicked the callback is called with
     *  the clicked card and the callback is reset. The callback's signature should be:
     *
     *      function callback (card :Card) :void 
     *
     *  @throws CardException if this array is empty since otherwise the callback will not occur. */
    public function enable (callback :Function) :void
    {
        if (_cards.length == 0) {
            throw new CardException("Enabling an empty card array");
        }

        for (var i :int = 0; i < _cards.length; ++i) {
            _cards[i].enabled = true;
        }

        _callback = callback;
    }
    
    /** Enable clicking on specific cards. When a card is clicked the callback is called with
     *  the clicked card and the callback is reset. The callback's signature should be:
     *
     *      function callback (card :Card) :void 
     *
     *  @throws CardException is the resulting set of enabled cards is empty since otherwise
     *  the callback would not occur. */
    public function enableSome (cards :CardArray, callback :Function) :void
    {
        var count :int = 0;

        // todo: make linear time N + M instead of quadratic N * M
        for (var i :int = 0; i < _cards.length; ++i) {
            var enable :Boolean = cards.has(_cards[i]);
            _cards[i].enabled = enable;
            if (enable) {
                ++count;
            }
        }

        if (count == 0) {
            throw new CardException("Enabling zero cards");
        }

        _callback = callback;
    }
    
    /** @inheritDoc */
    public function toString () :String
    {
        var s :String = "";
        var first :Boolean = true;
        for (var i :int = 0; i < _cards.length; ++i)
        {
            if (!first) s += ", ";
            s += _cards[i].toString();
            first = false;
        }
        return s;
    }

    /** The callback function for the sprite's click handling. */
    protected function onClick (card :Card) :void
    {
        Log.getLog(this).info("Card selected: " + card);
        if (_callback != null) {
            _callback(card);
            _callback = null;
        }
    }

    /** The ordinals. */
    protected var _ordinals :Array = new Array();

    /** The Card objects. */
    protected var _cards :Array = new Array();

    /** The display object (may be null). */
    protected var _display :CardArraySprite;

    /** The callback function if cards have been enabled for clicking. */
    protected var _callback :Function;
}

}

import flash.display.Sprite;
import flash.events.MouseEvent;
import spades.*;

/** File-private placeholder class for displaying a CardArray. Adds the display of each card in the 
 *  array and lays them out trivially. */
class CardArraySprite extends Sprite
{
    public function CardArraySprite (array :CardArray, callback :Function) {
        var cards :Array = array.cards;
        for (var i :int = 0; i < cards.length; ++i) {
            var card :Card = cards[i] as Card;
            addChild(card.display);
            var x :int = i * Card.SPRITE_WIDTH / 2;
            card.display.x = x;
            card.display.y = 0;
            width = x + card.display.width;
            height = card.display.height;
        }

        addEventListener(MouseEvent.CLICK, mouseClick);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOut);

        _callback = callback;
        _array = array;
    }

    protected function mouseClick (event :MouseEvent) :void {
        var index :int = roll(event.target);
        if (index >= 0 && index <= _array.length) {
            _callback(_array.cards[index]);
            roll(null);
        }
    }

    protected function mouseMove (event :MouseEvent) :void {
        roll(event.target);
    }

    protected function mouseOut (event :MouseEvent) :void {
        roll(null);
    }

    protected function roll (target :Object) :int {
        var index :int = -1;
        for (var i :int = 0; i < _array.length; ++i) {
            var card :Card = _array.cards[i] as Card;
            if (card.display == target) {
                card.highlighted = true;
                index = i;
                break;
            }
            else {
                card.highlighted = false;
            }
        }
        
        return index;
    }

    protected var _array :CardArray;
    protected var _callback :Function;
}
