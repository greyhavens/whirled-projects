package vampire.server.statistics
{
import flash.events.Event;

public class StatisticsEvent extends Event
{
    public function StatisticsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
    {
        super(STATS, false, false);
        
    }
    public static const STATS :String = "Stats Msg";
    
}
}
