package joingame.net
{
    public class ResetViewToModelMessage extends JoinGameMessage
    {
        public function ResetViewToModelMessage(playerId:int = -1)
        {
            super(playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        public static const NAME :String = "Server:Reset View To Model";        
    }
}