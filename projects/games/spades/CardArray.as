package {

import flash.display.DisplayObject;

/**
 * An ordered container of cards with an optional display component. Maintains consistency between 
 * an array of ordinals (integers) for use in serialization and an array of Card objects for 
 * rendering and game logic. The class may be extended as needed for use in spades and other card 
 * games.
 */
public class CardArray
{
    /** A full deck of cards. Users promise not to modify the deck. */
    public static const FULL_DECK:CardArray = makeDeck();

    /** Create a new full deck. Users may modify the result. */
    public static function makeDeck ():CardArray
    {
        var ordinals:Array = new Array(Card.NUM_ORDINALS);
        for (var i:int = 0; i < ordinals.length; ++i) {
            ordinals[i] = i;
        }

        return new CardArray(ordinals);
    }
    
    /**
     * Create a new container.
     * @param ordinals optional array or ordinal values for initial contents
     * @throws CardException if any contents are not valid.
     */
    public function CardArray (ordinals:Array=null)
    {
        if (ordinals != null) {
            for (var i:int = 0; i < ordinals.length; ++i) {
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
    public function get display ():DisplayObject
    {
        if (_display == null) {
            _display = new CardArraySprite(this);
        }

        return _display;
    }

    /** Access the underlying array of ordinal values. */
    public function get ordinals ():Array
    {
        return _ordinals;
    }
    
    /** Access the underlying array of card objects. */
    public function get cards ():Array
    {
        return _cards;
    }
    
    /** Add a new card to the end by ordinal value. */
    public function pushOrdinal (ordinal:int):void
    {
        pushCard(Card.createCard(ordinal));
    }

    /** Add a new card to the end. */
    public function pushCard (card:Card):void
    {
        _ordinals.push(card.ordinal);
        _cards.push(card);
    }
    
    /** @inheritDocs */
    public function toString ():String
    {
        var s:String = "";
        var first:Boolean = true;
        for (var i:int = 0; i < _cards.length; ++i)
        {
            if (!first) s += ", ";
            s += _cards[i].toString();
            first = false;
        }
        return s;
    }

    /** The ordinals. */
    protected var _ordinals:Array = new Array();

    /** The Card objects. */
    protected var _cards:Array = new Array();

    /** The display object (may be null). */
    protected var _display:DisplayObject;
}

}

import flash.display.Sprite;

/** File-private placeholder class for displaying a CardArray. Adds the display of each card in the 
 *  array and lays them out trivially. */
class CardArraySprite extends Sprite
{
    public function CardArraySprite (array:CardArray) {
        var cards:Array = array.cards;
        for (var i:int = 0; i < cards.length; ++i) {
            var card:Card = cards[i] as Card;
            addChild(card.display);
            var x:int = i * Card.SPRITE_WIDTH / 2;
            card.display.x = x;
            card.display.y = 0;
            width = x + card.display.width;
            height = card.display.height;
        }
    }
}
