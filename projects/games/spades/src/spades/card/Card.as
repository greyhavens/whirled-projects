package spades.card {

import flash.display.DisplayObject;

/**
 * Represents a card for use with game logic, rendering and UI. Has suit, rank and all constants for 
 * a normal deck. Also provides translation to and from "ordinal" cards for use in serialization.
 * TODO: jokers
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

    /** Array of standard suits. */
    public static const SUITS :Array = [
        SUIT_HEARTS, SUIT_SPADES, SUIT_CLUBS, SUIT_DIAMONDS];

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

    public static const RANKS :Array = [
        RANK_ACE, RANK_TWO, RANK_THREE, RANK_FOUR, RANK_FIVE, RANK_SIX, 
        RANK_SEVEN, RANK_EIGHT, RANK_NINE, RANK_TEN, RANK_JACK, RANK_QUEEN,
        RANK_KING];

    /** Number of suits. NOTE: also used as a bit mask. */
    public static const MAX_SUIT :int = 7;

    /** Maximum rank value. NOTE: also used as a  bit mask. */
    public static const MAX_RANK :int = 31;

    /** Constant for straight rank ordering. */
    public static const RANK_ORDER_NORMAL :int = 0;

    /** Constant for aces high rank ordering. */
    public static const RANK_ORDER_ACES_HIGH :int = 1;
    
    /** Number of ranks. */
    public static const NUM_RANK_ORDERS :int = 2;

    /** Number or ordinals. NOTE: also used as a bit mask */
    public static const MAX_ORDINAL :int = 255;

    /** Placeholder value for the width of a card sprite. */
    public static const SPRITE_WIDTH :int = 70;

    /** Placeholder value for the height of a card sprite. */
    public static const SPRITE_HEIGHT :int = 100;

    /** Create a new Card object from an ordinal.
     *  @throws CardException if the ordinal is not valid. */
    public static function createCardFromOrdinal (ordinal :int) :Card
    {
        if (ordinal < 0 || ordinal > MAX_ORDINAL) {
            throw new CardException("" + ordinal + " is not in range");
        }
        
        var suit :int = (ordinal >> 5) & MAX_ORDINAL;
        var rank :int = (ordinal & MAX_RANK);
        return new Card(suit, rank);
    }
    
    /** Create a new face down card. A face down card usually means that the local player "has" 
     *  the card but cannot yet see its value, i.e. the value is not known. */
    public static function createFaceDownCard () :Card
    {
        return createCardFromOrdinal(MAX_ORDINAL);
    }
    
    /** Return a short string for a SUIT_* constant for use in debugging or naming 
     *  conventions. For example, SUIT_HEARTS is "H". If the suit is not one defined
     *  in this class, the string is calcualted from the numeric value. */
    public static function suitString (suit :int) :String
    {
        switch (suit) {
            case SUIT_HEARTS : return "H";
            case SUIT_DIAMONDS : return "D";
            case SUIT_CLUBS : return "C";
            case SUIT_SPADES : return "S";
            default : return "(Suit " + suit + ")";
        }
    }
    
    /** Return a short string for a RANK_* constant for use in debugging or naming 
     *  conventions. For example, RANK_ACE is "A". If the rank is not one defined 
     *  by this class, the string is calculated from the numeric value. */
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
            default : return "(Rank " + rank + ")";
        }
    }

    /** Compare two ranks in the given ordering.
     *  @param rank1 the first rank to compare, one of the RANK_* constants
     *  @param rank2 the second rank to compare, one of the RANK_* constants
     *  @param ordering how to compare, one of the RANK_ORDER_* constants
     *  @throws CardException if any constant is not in the predefined set
     *  @return a negative number if rank1 < rank2, positive if rank1 > rank2 and zero 
     *  if rank1 == rank2 */
    public static function compareRanks(
        rank1 :int, 
        rank2 :int, 
        ordering: int=RANK_ORDER_NORMAL) :int
    {
        validate("Rank", rank1, MAX_RANK + 1);
        validate("Rank", rank2, MAX_RANK + 1);
        validate("Rank order", ordering, NUM_RANK_ORDERS);

        switch (ordering) {

        case RANK_ORDER_NORMAL:
            break;

        case RANK_ORDER_ACES_HIGH:
            if (rank1 == RANK_ACE) {
                rank1 = RANK_KING + 1;
            }
            if (rank2 == RANK_ACE) {
                rank2 = RANK_KING + 1;
            }
            break;

        default:
            throw new CardException("Ordering " + ordering + " not handled");
        }

        return rank1 - rank2;
    }

    /**
     * Create a new card.
     * @param suit the suit of the card (one of the SUIT_* constants)
     * @param rank the rank of the card (one of the RANK_* constants)
     * @throws CardException if the suit or rank is invalid.
     */
    public function Card (suit :int, rank :int) :void
    {
        validate("Rank", rank, MAX_RANK + 1);
        validate("Suit", suit, MAX_SUIT + 1);

        _ordinal = (suit << 5) | rank;
    }

    /** Access the rank. */
    public function get rank () :int
    {
        return (_ordinal & MAX_RANK);
    }

    /** Access the suit. */
    public function get suit () :int
    {
        return (_ordinal >> 5) & MAX_SUIT;
    }

    /** Access the ordinal. */
    public function get ordinal () :int
    {
        return _ordinal;
    }
    
    /** Compare for eqaulity to another card.
     *  @return true if the this is equal to the other card */
    public function equals (rhs :Card) :Boolean
    {
        if (rhs == null) {
            return false;
        }
        
        return _ordinal == rhs._ordinal;
    }

    /** Access whether the card is face down or not. */
    public function get faceDown () :Boolean
    {
        return _ordinal == MAX_ORDINAL;
    }

    /** Get a unique string representation of this card for debugging or naming conventions. 
     *  E.g. "two of hearts" is "2H". */
    public function get string () :String
    {
        return rankString(rank) + suitString(suit);
    }
    
    /** @inheritDoc */
    public function toString () :String
    {
        return string;
    }

    /** Check if this card has a better rank than the other.
     *  @param ordering how to compare, one of the RANK_ORDER_* constants 
     *  @param rhs card to compare against */
    public function isBetterRank (rhs :Card, ordering :int) :Boolean
    {
        var cmp :int = compareRanks(rank, rhs.rank, ordering);
        return cmp > 0;
    }

    /** Throw an exception if the value is less than zero or larger than max.
     *  @param type the ordinal name of the value set */
    protected static function validate(type :String, value :int, num :int) :void
    {
        if (value < 0 || value >= num) {
            throw new CardException(type + value + " is not valid");
        }
    }

    /** The rank (3 high bits) and suit (5 low bits). */
    protected var _ordinal :int;
}

}

