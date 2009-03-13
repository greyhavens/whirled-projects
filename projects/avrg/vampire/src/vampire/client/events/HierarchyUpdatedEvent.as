package vampire.client.events
{
    import flash.events.Event;

    import vampire.data.Lineage;

    public class HierarchyUpdatedEvent extends Event
    {
        public function HierarchyUpdatedEvent( h:Lineage, playerWithNewMinion :int = 0)
        {
            super(HIERARCHY_UPDATED, false, false);
            _hierarchy = h;
            _playerGainedMinion = playerWithNewMinion;
        }

        public function get hierarchy() :Lineage
        {
            return _hierarchy;
        }

        public function get playerGainedMinion() :int
        {
            return _playerGainedMinion;
        }

        protected var _hierarchy :Lineage;
        protected var _playerGainedMinion :int;

        public static const HIERARCHY_UPDATED :String = "Hierarchy Updated";

    }
}