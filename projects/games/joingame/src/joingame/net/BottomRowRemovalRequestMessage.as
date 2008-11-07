package joingame.net
{
    public class BottomRowRemovalRequestMessage extends JoinGameMessage
    {
        public function BottomRowRemovalRequestMessage(playerId:int)
        {
            super(playerId);
        }
    
        public static const NAME :String = "Server:Board Remove Row Request";        
    }
}