package joingame.net
{
    public class PlayerReceivedGameStateMessage extends JoinGameMessage
    {
        public function PlayerReceivedGameStateMessage(playerId:int = -1)
        {
            super( playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        
        public static const NAME :String = "Server:Player Recieved Start Game State";        
    }
}