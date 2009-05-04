package vampire.server
{
import flash.events.Event;

public class PlayerMovedEvent extends Event
{
    public function PlayerMovedEvent(type:String, player :PlayerData, room :Room)
    {
        super(type, false, false);
        _player = player;
        _room = room;
    }

    public function get room () :Room
    {
        return _room;
    }

    public function get player () :PlayerData
    {
        return _player;
    }

    protected var _room :Room;
    protected var _player :PlayerData;

    public static const PLAYER_ENTERED_ROOM :String = "PlayerEnteredRoom";
    public static const PLAYER_LEFT_ROOM :String = "PlayerLeftRoom";
}
}