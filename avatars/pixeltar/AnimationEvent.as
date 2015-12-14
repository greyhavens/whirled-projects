package {

import flash.events.Event;

public class AnimationEvent extends Event
{
    public static const UPDATE :String = "update";
    public static const COMPLETE :String = "complete";

    public var frame :int;

    public function AnimationEvent(type :String, frame :int)
    {
        super(type);

        this.frame = frame;
    }
}

}
