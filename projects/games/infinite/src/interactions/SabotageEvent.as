package interactions
{
    import flash.events.Event;

    public class SabotageEvent extends Event
    {
        public var sabotage:Sabotage;
        
        public function SabotageEvent(type:String, sabotage:Sabotage)
        {
            super(type, bubbles, cancelable);
            this.sabotage = sabotage;
        }        
  
        public static const TRIGGERED:String = "sabotage_triggered";           
    }
}