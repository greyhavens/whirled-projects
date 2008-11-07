package joingame.net
{
    public class BoardRowRemoveConfirmtoServer extends JoinGameMessage
    {
        public function BoardRowRemoveConfirmtoServer(playerId:int = -1)
        {
            super(playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        
        public static const NAME :String = "Server:Board Remove Row Confirm Server Only";
        
    }
}