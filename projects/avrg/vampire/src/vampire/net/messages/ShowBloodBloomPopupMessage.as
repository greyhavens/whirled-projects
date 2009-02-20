package vampire.net.messages
{
    
/**
 * Send from the server to current bloodbloom players showing the popup to start the game.
 * 
 */
public class ShowBloodBloomPopupMessage extends BaseGameMessage
{
    public function ShowBloodBloomPopupMessage(playerId:int)
    {
        super(-1);
    }
    
    
    
}
}