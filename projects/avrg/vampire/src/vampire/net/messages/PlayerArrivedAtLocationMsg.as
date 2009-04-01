package vampire.net.messages
{
import vampire.net.messages.BaseGameMsg;

public class PlayerArrivedAtLocationMsg extends BaseGameMsg
{
    public function PlayerArrivedAtLocationMsg(playerId :int = 0)
    {
        super(playerId);
    }

    override public function get name () :String
    {
       return NAME;
    }

    public static const NAME :String = "Message: PlayerArrivedAtLocation";

}
}