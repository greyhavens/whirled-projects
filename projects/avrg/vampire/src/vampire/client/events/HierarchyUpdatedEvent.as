package vampire.client.events
{
    import flash.events.Event;

    import vampire.data.MinionHierarchy;

    public class HierarchyUpdatedEvent extends Event
    {
        public function HierarchyUpdatedEvent( h:MinionHierarchy, playerWithNewMinion :int = 0)
        {
            super(HIERARCHY_UPDATED, false, false);
            _hierarchy = h;
            _playerGainedMinion = playerWithNewMinion;
        }

        public function get hierarchy() :MinionHierarchy
        {
            return _hierarchy;
        }

        public function get playerGainedMinion() :int
        {
            return _playerGainedMinion;
        }

        protected var _hierarchy :MinionHierarchy;
        protected var _playerGainedMinion :int;

        public static const HIERARCHY_UPDATED :String = "Hierarchy Updated";

    }
}