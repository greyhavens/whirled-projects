package spades.card {

import flash.events.Event;

/** 
 * Represents something that happens to a hand of cards.
 */
public class HandEvent extends Event
{
    /** The type of event when the hand is dealt. For this event, the cards property is the new 
     *  contents of the hand and the player, count and targetPlayer properties are not used. */
    public static const DEALT :String = "hand.dealt";

    /** The type of event when cards are passed to the hand from another player. For this event,
     *  the cards property is the passed cards (if available), the player is the id of the player 
     *  who has passed them, the count property is the number of cards passed and the targetPlayer
     *  is the id of the player receiving the passed cards. */
    public static const PASSED :String = "hand.passed";

    /** The type of event when the rules of the game require the local player to pass cards. For
     *  this event type, the cards property is not used, the player property is the id of the 
     *  player who is required to pass, the count property is the number of cards that should be 
     *  passed and the targetPlayer is the player who will receive the passed cards. */
    public static const PASS_REQUESTED :String = "hand.requested";

    /** The type of event when it is the player's turn. For this event, the cards property is set
     *  to the set of cards that are allowed according to the game rules and the count property is
     *  set to the number of cards that should be played. The player and targetPlayer properties
     *  are not used. */
    public static const ALLOWED_PLAY :String = "hand.allowedPlay";

    /** The type of event when the local player may choose some cards, but not yet play them's turn. 
     *  For this event, the cards property is set to the set of cards that are allowed to be 
     *  selected (according to the game rules or game presentation) and the count property is
     *  set to the number of cards that may be selected. The player and targetPlayer properties
     *  are not used. */
    public static const ALLOWED_SELECTION :String = "hand.allowedSelection";

    /** The type of event sent when the local player can no longer select or play any cards. For 
     *  this event, no properties are used. */
    public static const DISALLOWED_SELECTION :String = "hand.disallowedSelection";

    /** The type of event sent when cards have been selected for play. For this event, the cards 
     *  property indicates the selected ones and the other properties are not used. */
    public static const CARDS_PLAYED :String = "hand.played";

    /** Create a new HandEvent. */
    public function HandEvent(
        type :String, 
        cards :CardArray = null,
        player :int = 0,
        count :int = 0,
        targetPlayer :int = 0)
    {
        super(type);
        _cards = cards;
        _player = player;
        _count = count;
        _targetPlayer = targetPlayer;
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
            "cards", "player", "count", "targetPlayer");
    }

    /** The player that passed or requested to pass the cards. */
    public function get player () :int
    {
        return _player;
    }

    /** The player that is being passed to. */
    public function get targetPlayer () :int
    {
        return _targetPlayer;
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
    protected var _targetPlayer :int;
}

}
