package vampire.quest {

import flash.events.Event;

public class ActivityEvent extends Event
{
    public static const ACTIVITY_ADDED :String = "ActivityAdded";

    public var activity :ActivityDesc;

    public function ActivityEvent (type :String, activity :ActivityDesc)
    {
        super(type);
        this.activity = activity;
    }

    override public function clone () :Event
    {
        return new ActivityEvent(type, activity);
    }
}

}
