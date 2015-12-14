package vampire.quest.activity {

public class ActivityParams
{
    public var minPlayers :int;
    public var maxPlayers :int;

    public function ActivityParams (minPlayers :int, maxPlayers :int)
    {
        this.minPlayers = minPlayers;
        this.maxPlayers = maxPlayers;
    }

    public function get isLobbied () :Boolean
    {
        return maxPlayers > 1;
    }
}

}
