package vampire.net.messages
{
public class TargetMovedMsg extends BaseGameMsg
{
    public function TargetMovedMsg (playerId:int = 0)
    {
        super(playerId);
    }
    override public function get name () :String
    {
       return NAME;
    }
    public static const NAME :String = "Message: Target Moved";
}
}