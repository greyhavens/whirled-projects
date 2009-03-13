package vampire.client.events
{
    import flash.events.Event;

    import vampire.data.Lineage;

    public class LineageUpdatedEvent extends Event
    {
        public function LineageUpdatedEvent( h:Lineage, playerWithNewMinion :int = 0)
        {
            super(LINEAGE_UPDATED, false, false);
            _lineage = h;
            _playerGainedMinion = playerWithNewMinion;
        }

        public function get lineage() :Lineage
        {
            return _lineage;
        }

        public function get playerGainedMinion() :int
        {
            return _playerGainedMinion;
        }

        protected var _lineage :Lineage;
        protected var _playerGainedMinion :int;

        public static const LINEAGE_UPDATED :String = "Lineage Updated";

    }
}