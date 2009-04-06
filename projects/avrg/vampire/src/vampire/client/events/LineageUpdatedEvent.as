package vampire.client.events
{
    import flash.events.Event;

    import vampire.data.Lineage;

    public class LineageUpdatedEvent extends Event
    {
        public function LineageUpdatedEvent(h:Lineage, playerWithNewProgeny :int = 0)
        {
            super(LINEAGE_UPDATED, false, false);
            _lineage = h;
            _playerGainedProgeny = playerWithNewProgeny;
        }

        public function get lineage() :Lineage
        {
            return _lineage;
        }

        public function get playerGainedProgeny() :int
        {
            return _playerGainedProgeny;
        }

        protected var _lineage :Lineage;
        protected var _playerGainedProgeny :int;

        public static const LINEAGE_UPDATED :String = "Lineage Updated";

    }
}