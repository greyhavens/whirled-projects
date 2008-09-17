package bingo.client {

import flash.events.Event;

public class LocalStateChangedEvent extends Event
{
    public static const CARD_COMPLETED :String = "cardCompleted";

    public function LocalStateChangedEvent (type :String)
    {
        super(type, false, false);
    }

}

}
