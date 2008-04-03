package spades.card {

import flash.events.Event;

/** 
 * Represents something that happens to a hand of cards.
 */
public class HandEvent extends Event
{
    /** The type of event when the hand is dealt. For this event, the cards property is the new 
     *  contents of the hand and the player and count properties are not used. */
    public static const DEALT :String = "hand.dealt";

    /** The type of event when cards are passed to the hand from another player. For this event,
     *  the cards property is the passed cards and the player is the id of the player who has 
     *  passed them. The count property is not used. */
    public static const PASSED :String = "hand.passed";

    /** The type of event when the rules of the game require the local player to pass cards. For
     *  this event type, the cards property is not used, the player property is the player 
     *  requesting the cards and the count property is the number of cards requested. */
    public static const PASS_REQUESTED :String = "hand.requested";

    /** The type of event when it is the player's turn. For this event, the cards property is set
     *  to the set of cards that are allowed according to the game rules and the count property is
     *  set to the number of cards that should be playerd. The player property is not used. */
    public static const BEGAN_TURN :String = "hand.beganturn";

    /** The type of event sent when it is no longer the player's turn. For this event, no 
     *  properties are used. */
    public static const ENDED_TURN :String = "hand.endedturn";

    /** The type of event sent when cards have been selected for play. For this event, the cards 
     *  property indicates the selected ones and the other properties are not used. */
    public static const CARDS_SELECTED :String = "hand.played";

    /** Create a new TrickEvent. */
    public function HandEvent(
        type :String, 
        cards :CardArray = null,
        player :int = 0,
        count :int = 0)
    {
        super(type);
        _cards = cards;
        _player = player;
        _count = count;
    }

    /** @inheritDoc */
    // from flash.events.Event
    public override function clone () :Event
    {
        return new HandEvent(type, _cards, _player);
    }

    /** @inheritDoc */
    // from Object
    public override function toString () :String
    {
        return formatToString("HandEvent", "type", "bubbles", "cancelable", 
            "cards", "player", "count");
    }

    /** The player that passed or requested to pass the cards. */
    public function get player () :int
    {
        return _player;
    }

    /** The cards that have been dealt or passed. */
    public function get cards () :CardArray
    {
        return _cards;
    }

    /** The number of cards requested to be passed. */
    public function get count () :int
    {
        return _count;
    }

    protected var _player :int;
    protected var _cards :CardArray;
    protected var _count :int;
}

}
