package vampire.client.events
{
import flash.events.Event;

public class TutorialActionPerformedEvent extends Event
{
    public function TutorialActionPerformedEvent(type:String)
    {
        super(type, false, false);
    }


    public static const TUTORIAL_ACTION :String = "";
}
}