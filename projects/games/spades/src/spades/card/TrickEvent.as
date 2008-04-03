package spades.card {

import flash.events.Event;

/** 
 * Represents something that happens to a trick.
 */
public class TrickEvent extends Event
{
    /** The type of event when a card is played. For this event, the card property is set to the 
     *  card played and the player property is set to the player who played the card. */
    public static const CARD_PLAYED :String = "trick.cardPlayed";

    /** The type of event when the trick is reset. For this event, the card and player properties 
     *  are not set.*/
    public static const RESET :String = "trick.reset";

    /** The type of event when the trick is complete. For this event, the card property is set to 
     *  the winning card and the player property to the winning player and the player property is 
     *  set to the winner. */
    public static const COMPLETED :String = "trick.complete";

    /** The type of event when the player who is currently winning the trick is changed. For this 
     *  event, the card is set to the card that has just been played and the player is set to the 
     *  winning player. */
    public static const FRONTRUNNER_CHANGED :String = "trick.frontrunner";

    /** Create a new TrickEvent. */
    public function TrickEvent(
        type :String, 
        card :Card = null, 
        player :int = 0)
    {
        super(type);
        _card = card;
        _player = player;
    }

    /** @inheritDoc */
    // from flash.events.Event
    public override function clone () :Event
    {
        return new TrickEvent(type, _card, _player);
    }

    /** @inheritDoc */
    // from Object
    public override function toString () :String
    {
        return formatToString("TrickEvent", "type", "bubbles", "cancelable", 
            "card", "player");
    }

    /** The player that put down the card or the player that has won the trick. */
    public function get player () :int
    {
        return _player;
    }

    /** The card that has been played or the card that has won the trick. */
    public function get card () :Card
    {
        return _card;
    }

    protected var _player :int;
    protected var _card :Card;
}

}
