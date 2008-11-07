package joingame.net
{
    public class ReplayRequestMessage extends JoinGameMessage
    {
        public function ReplayRequestMessage(playerId:int = -1)
        {
            super( playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }

        public static const NAME :String = "Server:Request Replay";        
    }
}