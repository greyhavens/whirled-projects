package vampire.net.messages
{
public class MovePredAfterFeedingMsg extends BaseGameMsg
{
    public function MovePredAfterFeedingMsg(playerId:int = 0)
    {
        super(playerId);
    }

    override public function get name () :String
    {
       return NAME;
    }

    public static const NAME :String = "Message: Move Predator After Feeding";

}
}
