package joingame.net
{
    public class PlayerDestroyedMessage extends JoinGameMessage
    {
        public function PlayerDestroyedMessage(playerId:int = -1)
        {
            super(playerId);
        }
        
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        
        public function toString() :String
        {
            return NAME + " " + playerId;
        }
        
        public static const NAME :String = "Server:Player Destroyed";
        
    }
}