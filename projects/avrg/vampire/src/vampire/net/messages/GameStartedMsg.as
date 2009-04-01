package vampire.net.messages
{
/**
 * Notify the server that the game was sucessfully started.  This means that the avatar
 * is a legal one.
 */
public class GameStartedMsg extends BaseGameMsg
{
    public function GameStartedMsg (playerId:int = 0)
    {
        super(playerId);
    }

    override public function get name () :String
    {
       return NAME;
    }

    public static const NAME :String = "Message: Game started";
}
}