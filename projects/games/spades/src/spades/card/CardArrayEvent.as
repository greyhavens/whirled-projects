package spades.card {

import flash.events.Event;

/** 
 * Represents something that happens to a card array.
 */
public class CardArrayEvent extends Event
{
    /** The type of event. */
    public static const CARD_ARRAY :String = "cardArray";

    /** Action property when a card was added. */
    public static const ACTION_ADDED :int = 0;

    /** Action property when a card was removed. */
    public static const ACTION_REMOVED :int = 1;

    /** Action property when the array is about to reset. */
    public static const ACTION_PRERESET :int = 2;

    /** Action property when the array was reset. */
    public static const ACTION_RESET :int = 3;

    /** Create a new event for a card that has been added. The index is the position within the 
     *  parent CardArray that the new card has been added to. */
    public static function added (card :Card, index :int) :CardArrayEvent
    {
        return new CardArrayEvent(ACTION_ADDED, card, index);
    }

    /** Create a new event for a card that has been removed. The index is the position within the 
     *  parent CardArray that the card was in prior to removal. */
    public static function removed (card :Card, index :int) :CardArrayEvent
    {
        return new CardArrayEvent(ACTION_REMOVED, card, index);
    }

    /** Create a new event for when a card array has been completely emptied. */
    public static function reset () :CardArrayEvent
    {
        return new CardArrayEvent(ACTION_RESET, null, -1);
    }

    /** Create a new event for when a card array has been completely emptied. */
    public static function preReset () :CardArrayEvent
    {
        return new CardArrayEvent(ACTION_PRERESET, null, -1);
    }

    /** @inheritDoc */
    // from flash.events.Event
    public override function clone () :Event
    {
        return new CardArrayEvent(_action, _card, _index);
    }

    /** @inheritDoc */
    // from Object
    public override function toString () :String
    {
        return formatToString("CardEvent", "type", "bubbles", "cancelable", 
            "action", "card", "index");
    }

    /** The action taken on the card array, one of the ACTION_* constants. */
    public function get action () :int
    {
        return _action;
    }

    /** The card that has been added or removed. Not relevant for a reset event. */
    public function get card () :Card
    {
        return _card;
    }

    /** The index of the the card that has been added or removed. Not relevant for a reset event. */
    public function get index () :int
    {
        return _index;
    }

    /** Protect constructor since the card and index must be both or neither. */
    function CardArrayEvent(action :int, card :Card, index :int)
    {
        super(CARD_ARRAY);
        _action = action;
        _card = card;
        _index = index;
    }

    protected var _action :int;
    protected var _card :Card;
    protected var _index :int;
}

}
