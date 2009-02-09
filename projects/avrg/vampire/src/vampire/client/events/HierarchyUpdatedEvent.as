package vampire.client.events
{
    import flash.events.Event;
    
    import vampire.data.MinionHierarchy;

    public class HierarchyUpdatedEvent extends Event
    {
        public function HierarchyUpdatedEvent( h:MinionHierarchy)
        {
            super(HIERARCHY_UPDATED, false, false);
            hierarchy = h;
        }
        
        public var hierarchy :MinionHierarchy;
        
        public static const HIERARCHY_UPDATED :String = "Hierarchy Updated";
        
    }
}