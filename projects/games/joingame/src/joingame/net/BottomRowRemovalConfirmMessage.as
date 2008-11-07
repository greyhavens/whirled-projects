package joingame.net
{
    public class BottomRowRemovalConfirmMessage extends JoinGameMessage
    {
        public function BottomRowRemovalConfirmMessage(playerId:int = -1)
        {
            super(playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        

        
        
        public static const NAME :String = "Server:Board Remove Row Confirm";        
    }
}