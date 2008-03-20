package {

import flash.display.DisplayObject;

/**
 * Represents a card for use with game logic, rendering and UI. Has suit, rank and an optional 
 * display component. Also provides translation to and from "ordinal" cards for use in 
 * serialization.
 * XXTODO Are jokers needed?
 */
public class Card
{
    /** Constant for the suit of hearts. */
    public static const SUIT_HEARTS :int = 0;

    /** Constant for the suit of spades. */
    public static const SUIT_SPADES :int = 1;

    /** Constant for the suit of clubs. */
    public static const SUIT_CLUBS :int = 2;

    /** Constant for the suit of diamonds. */
    public static const SUIT_DIAMONDS :int = 3;

    /** Constant for the rank of ace. */
    public static const RANK_ACE :int = 0;

    /** Constant for the rank of deuce. */
    public static const RANK_TWO :int = 1;

    /** Constant for the rank of three. */
    public static const RANK_THREE :int = 2;

    /** Constant for the rank of four. */
    public static const RANK_FOUR :int = 3;

    /** Constant for the rank of five. */
    public static const RANK_FIVE :int = 4;

    /** Constant for the rank of six. */
    public static const RANK_SIX :int = 5;

    /** Constant for the rank of seven. */
    public static const RANK_SEVEN :int = 6;

    /** Constant for the rank of eight. */
    public static const RANK_EIGHT :int = 7;

    /** Constant for the rank of nine. */
    public static const RANK_NINE :int = 8;

    /** Constant for the rank of ten. */
    public static const RANK_TEN :int = 9;

    /** Constant for the rank of jack. */
    public static const RANK_JACK :int = 10;

    /** Constant for the rank of queen. */
    public static const RANK_QUEEN :int = 11;

    /** Constant for the rank of king. */
    public static const RANK_KING :int = 12;
    
    /** Number of suits. */
    public static const NUM_SUITS :int = 4;

    /** Number of ranks. */
    public static const NUM_RANKS :int = 13;

    /** Number or ordinals (also the number of cards in a standard deck). */
    public static const NUM_ORDINALS :int = NUM_SUITS * NUM_RANKS;

    /** Placeholder value for the width of a card sprite. 
     *  XXTODO use card.display.width instead? */
    public static const SPRITE_WIDTH :int = 70;

    /** Placeholder value for the height of a card sprite.
     *  XXTODO use card.display.height instead? */
    public static const SPRITE_HEIGHT :int = 105;

    /** Create a new Card object from an ordinal.
     *  @throws CardException if the ordinal is not valid. */
    public static function createCard (ordinal :int) :Card
    {
        if (ordinal < 0 || ordinal >= NUM_ORDINALS) {
            throw CardException("" + ordinal + " is not a valid card");
        }
        
        var suit :int = ordinal / NUM_RANKS;
        var rank :int = ordinal % NUM_RANKS;
        return new Card(suit, rank);
    }
    
    /** Return a short string for a SUIT_* constant for use in debugging or naming 
     *  conventions. For example, SUIT_HEARTS is "H".
     *  @throws CardException if the suit is not valid */
    public static function suitString (suit :int) :String
    {
        switch (suit) {
            case SUIT_HEARTS : return "H";
            case SUIT_DIAMONDS : return "D";
            case SUIT_CLUBS : return "C";
            case SUIT_SPADES : return "S";
            default : throw new CardException("" + suit + " is not a valid suit");
        }
    }
    
    /** Return a short string for a RANK_* constant for use in debugging or naming 
     *  conventions. For example, RANK_ACE is "A".
     *  @throws CardException if the rank is not valid */
    public static function rankString (rank :int) :String
    {
        switch (rank) {
            case RANK_ACE : return "A";
            case RANK_TWO : return "2";
            case RANK_THREE : return "3";
            case RANK_FOUR : return "4";
            case RANK_FIVE : return "5";
            case RANK_SIX : return "6";
            case RANK_SEVEN : return "7";
            case RANK_EIGHT : return "8";
            case RANK_NINE : return "9";
            case RANK_TEN : return "10";
            case RANK_JACK : return "J";
            case RANK_QUEEN : return "Q";
            case RANK_KING : return "K";
            default : throw new CardException("" + rank + " is not a valid rank");
        }
    }

    /** Return a long string for a SUIT_* constant. E.g. "hearts".
     *  XXTODO this is probably not useful, remove */
    static public function longSuitString (suit :int) :String
    {
        switch (suit) {
            case SUIT_HEARTS : return "hearts";
            case SUIT_DIAMONDS : return "diamonds";
            case SUIT_CLUBS : return "clubs";
            case SUIT_SPADES : return "spades";
            default : throw new CardException("" + suit + " is not a valid suit");
        }
    }
    
    /** Return a long string for a RANK_* constant. E.g. "queen".
     *  XXTODO this is probably not useful, remove */
    static public function longRankString (rank :int) :String
    {
        switch (rank)
        {
            case RANK_ACE : return "ace";
            case RANK_TWO : return "two";
            case RANK_THREE : return "three";
            case RANK_FOUR : return "four";
            case RANK_FIVE : return "five";
            case RANK_SIX : return "six";
            case RANK_SEVEN : return "seven";
            case RANK_EIGHT : return "eight";
            case RANK_NINE : return "nine";
            case RANK_TEN : return "ten";
            case RANK_JACK : return "jack";
            case RANK_QUEEN : return "queen";
            case RANK_KING : return "king";
            default : throw new CardException("" + rank + " is not a valid rank");
        }
    }

    /**
     * Create a new card.
     * @param suit the suit of the card (one of the SUIT_* constants)
     * @param rank the rank of the card (one of the RANK_* constants)
     * @throws CardException if the suit or rank is invalid.
     */
    public function Card (suit :int, rank :int) :void
    {
        if (rank < 0 || rank >= NUM_RANKS) {
            throw CardException("" + rank + " is not a valid rank");
        }
        
        if (suit < 0 || suit >= NUM_SUITS) {
            throw CardException("" + suit + " is not a valid suit");
        }

        _rank = rank;
        _suit = suit;
    }

    /** Access the display component (created on demand). */
    public function get display () :DisplayObject
    {
        if (_display == null) {
            _display = new CardText(this);
        }
        return _display;
    }

    /** Access the rank. */
    public function get rank () :int
    {
        return _rank;
    }

    /** Access the suit. */
    public function get suit () :int
    {
        return _suit;
    }

    /** Access the ordinal. */
    public function get ordinal () :int
    {
        return _suit * NUM_RANKS + _rank;
    }
    
    /** Compare for eqaulity to another card.
     *  @return true if the this is equal to the other card */
    public function equals (rhs :Card) :Boolean
    {
        if (rhs == null) {
            return false;
        }
        
        return _rank == rhs._rank && _suit == rhs._suit;
    }

    /** Get a unique string representation of this card for debugging or naming conventions. 
     *  E.g. "two of hearts" is "2H". */
    public function get string () :String
    {
        return rankString(_rank) + suitString(_suit);
    }
    
    /** Return a long string representing the card. E.g. "two of hearts". 
     *  XXTODO this is probably not useful, remove. */
    public function toLongString () :String
    {
        return longRankString(_rank) + " of " + suitString(_suit);
    }

    /** @inheritDoc */
    public function toString () :String
    {
        return string;
    }

    /** The rank. */
    protected var _rank :int;

    /** The suit. */
    protected var _suit :int;

    /** The display component (may be null) */
    protected var _display :DisplayObject;
}

}

import flash.text.TextField;

/** File-private placeholder for card graphics.
 *  XXTODO embed flashy stuff */
class CardText extends TextField
{
    public function CardText (card :Card) {
        // fixed size
        width = Card.SPRITE_WIDTH;
        height = Card.SPRITE_HEIGHT;

        // background
        background = true;
        backgroundColor = 0x77FF77;

        // border
        border = true;
        borderColor = 0x000000;

        // disallow selection
        selectable = false;

        // set multiline (rank then suit)
        multiline = true;

        // set text
        text = card.string;
    }
}
