package joingame.net
{
    public class PlayerRemovedMessage extends JoinGameMessage
    {
        public function PlayerRemovedMessage(playerId:int = -1)
        {
            super( playerId);
        }
        
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        public function toString() :String
        {
            return NAME + " " + playerId;
        }
        
        public static const NAME :String = "Server:Player Removed";
        
    }
}