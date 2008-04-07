package spades.card {

import flash.events.Event;

/** 
 * Represents something that happens to a card array.
 */
public class CardArrayEvent extends Event
{
    /** Type of event when a card is added. For this event type, the card property is set to the 
     *  card added and the index is set to the position the card was added at. */
    public static const ADDED :String = "cardarray.added";

    /** Type of event when a card is removed. For this event type, the card property is set to the 
     *  removed card and the index is set to the position from which it was removed. */
    public static const REMOVED :String = "cardarray.removed";

    /** Type of event when the array is about to be cleared and repopulated. For this event type,
     *  properties are not used. */
    public static const PRERESET :String = "cardarray.prereset";

    /** Type of event when the array has just been cleared and repopulated. For this event type, 
     *  properties are not used. */
    public static const RESET :String = "cardarray.reset";

    /** Create a new event constructor since the card and index must be both or neither. */
    public function CardArrayEvent(type :String, card :Card=null, index :int=-1)
    {
        super(type);
        _card = card;
        _index = index;
    }

    /** @inheritDoc */
    // from flash.events.Event
    public override function clone () :Event
    {
        return new CardArrayEvent(type, _card, _index);
    }

    /** @inheritDoc */
    // from Object
    public override function toString () :String
    {
        return formatToString("CardEvent", "type", "bubbles", "cancelable", 
            "card", "index");
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

    protected var _card :Card;
    protected var _index :int;
}

}
