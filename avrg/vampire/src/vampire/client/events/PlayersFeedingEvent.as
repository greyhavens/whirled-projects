package vampire.client.events
{
import flash.events.Event;

/**
 * Updates the playerIds who are feeding and unavailable for feeding.
 *
 */
public class PlayersFeedingEvent extends Event
{
    public function PlayersFeedingEvent (playersFeeding :Array)
    {
        super (PLAYERS_FEEDING, false, false);

        _playersFeeding = playersFeeding;
    }

    public function get playersFeeding () :Array
    {
        return _playersFeeding;
    }

    protected var _playersFeeding :Array;

    public static const PLAYERS_FEEDING :String = "PlayersFeeding";
}
}
