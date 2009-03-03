package vampire.client.events
{
    import flash.events.Event;

    import vampire.data.MinionHierarchy;

    public class HierarchyUpdatedEvent extends Event
    {
        public function HierarchyUpdatedEvent( h:MinionHierarchy, playerId :int = 0)
        {
            super(HIERARCHY_UPDATED, false, false);
            _hierarchy = h;
            _playerId = playerId;
        }

        public function get hierarchy() :MinionHierarchy
        {
            return _hierarchy;
        }

        public function get playerId() :int
        {
            return _playerId;
        }

        protected var _hierarchy :MinionHierarchy;
        protected var _playerId :int;

        public static const HIERARCHY_UPDATED :String = "Hierarchy Updated";

    }
}