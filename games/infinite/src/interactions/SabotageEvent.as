package interactions
{
    import flash.events.Event;

    public class SabotageEvent extends Event
    {
        public var sabotage:Sabotage;
        public var victimId:int;
        
        public function SabotageEvent(type:String, sabotage:Sabotage, victimId:int)
        {
            super(type, bubbles, cancelable);
            this.sabotage = sabotage;
            this.victimId = victimId;
        }        
    
        override public function clone() :Event
        {
            return new SabotageEvent(type, sabotage, victimId);
        }
  
        public static const TRIGGERED:String = "sabotage_triggered";           
    }
}