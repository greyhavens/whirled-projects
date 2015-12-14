package vampire.quest {

import flash.events.Event;

public class QuestPropEvent extends Event
{
    public static const PROP_CHANGED :String = "PropChanged";

    public var propName :String;

    public function QuestPropEvent (type :String, propName :String) :void
    {
        super(type);
        this.propName = propName;
    }

    override public function clone () :Event
    {
        return new QuestPropEvent(type, propName);
    }
}

}
