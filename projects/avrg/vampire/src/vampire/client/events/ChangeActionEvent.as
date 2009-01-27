package vampire.client.events
{
    import flash.events.Event;

    public class ChangeActionEvent extends Event
    {
        public function ChangeActionEvent(action :String)
        {
            super(CHANGE_ACTION, false, false);
            
            this.action = action;
        }
        
        public var action :String;
        
        public static const CHANGE_ACTION :String = "Change action";
    }
}